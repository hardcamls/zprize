---
layout: default
title: Field Multiplication
category: msm
subcategory: design
---

# Field Multiplication

A key operation is field multiplication in a prime field, ie: computing
`C = A * B mod P`, where P is a 377-bit prime number, and `A` and `B` are
both elements of the prime field (ie: `0 <= A < P`, A is an unsigned integer).

Our field multiplication has several requirements
- it's fully pipelined - in other words, it has a throughput of one per cycle
- $P$ is known at compile time
- $A$ and $B$ are known at runtime

## Computing $A × B$

The very first stage of the computation pipeline is to evaluate `A * B`.
The obvious way to implement this is.

The FPGA part we were working with comes with contains 6,800 DSP slices. Each
DSP slice is capable of performing an unsigned 27 x 16 multiplication. However,
we can realistically expect to use ~2500 of them. This is due to routing
congestion and the price of crossing SLRs.

Implementing a 377 by 377 multiplication naively with
[Long multiplication](https://en.wikipedia.org/wiki/Multiplication_algorithm#Long_multiplication)
would take up `ceil(377/17) * ceil(377/26) = 330` DSPs just to produce partial
results! This is not acceptable, as we need 7 field multiplications, each of
which requires 3 377-bit multiplications. This would require `330 * 3 * 7 = 6,930`
DSP slices, which is way above our budget!

We have instead implemented the
[Karatsuba-Ofman Multiplication Algorithm](https://en.wikipedia.org/wiki/Karatsuba_algorithm),
which requires less multiplication.

The key idea of the algorithm is to reexpress the multiplication as smaller
multiplication recursively, and reuse results to reduce the number of
multiplication.

For example, to multiply $x$ and $y$, firstly, express $x$ and $y$ as follows

$$
x = 2^{W/2}x_1 + x_0
$$

$$
y = 2^{W/2}y_1 + y_0
$$

where $x_1, y_1 < 2^{W/2}$, $x_0, y_0 < 2^{W/2}$ and $W$ as the number of bits to
represent $x$ and $y$. Since we're "splitting" the numbers as parts of powers of
two, this is simply a bit select (which is free in hardware!)

$$
x_1 = select\_bits(x_1, W - 1, W / 2)
$$

$$
x_0 = select\_bits(x_1, W / 2 - 1, 0)
$$

We break the computation into several stages:

**1) Pre adder stages**

$$ a = x_1 + x_0 $$

$$ b = y_1 + y_0 $$

**2) Recursive partial multiplication**

Then, the sub-multiplication, which are simply smaller karatsuba-ofman
multiplications (up to a base case, which we'll touch on later).

$$ z_2 = x_1 × y_0 $$

$$ z_0 = x_0 × y_0 $$

$$ m_1 = a × b $$

**3) Middle adder stages**

$$ z_1 = (m_1 - m_2) - z_2 - z_0 $$

**4) Post adder stages**

$$ xy = 2^{2W}z_2 + 2^{W}z_1 + z0 $$

The karatsuba ofman algorithm is a recursive algorithm, so we have the freedom
to choose the width where we fallback to a vanila multiplication with DSP
slices.  In practice, we experimentally found that the base case of W <= 26 works
best (it maps to exactly 2 DSP slices to compute multiplication of 2 numbers)

As it turns out, for 377-bit multiplications in the prime field, we only require
4 levels of recursion to arrive to a base case of 22-bit multipliers. This
translates to requiring only 162 DSP slices! This is much more realistic than
330 multipliers requires from long multiplication.

All the operations in the field multiplication is fully pipelined. This means
we can work out the exact latency of this component. In our work, we had
parameters to tune the amount of pipelining in each of the pre, middle
and post adder stages. This allowed us to easily experiment with various
multiplier design points.

## Barrett Reduction
When computing multiplications in modular arithmetic, we will necessarily need to reduce our
products within the modulus - in other words, given $A ⋅ B = q ⋅ P + r$, where $q, r$ are integers
and $r∈[0,P-1]$, we wish to find $r$. In the most general case, performing this reduction requires
us to divide the product by $P$, which is very expensive on FPGAs (because often, the best way to do
this is to simply long divide). However, in our specific case, we know that $P$ is a fixed constant,
so we can do better. We implement [Barrett Reduction](https://en.wikipedia.org/wiki/Barrett_reduction),
an efficient modular reduction algorithm, with several optimizations (discussed below).

The idea of the Barrett Reduction algorithm is to take the product $A ⋅ B$ and approximate $c$
based on 2 main stages.

### Stage 1: Coarse Approximation
We wish to compute $q = ⌊{ AB } / P⌋$. Let $n = ⌊ \log_2P ⌋$ be the number of bits needed to
represent $P$.

For the coarse approximation, we can approximate $q$ by approximating $1/P$ as $⌊2^{2n}/P⌋/2^{2n}$.
In other words, we take the $2n$ most significant bits of $1/P$ and use them as an approximation.
Letting $c = ⌊2^{2n}/P⌋ < 2^{n+1}$, our first approximation for $q$ is given by $q' = ⌊{ AB ⋅ c } / 2^{2n}⌋$.

However, note that this still requires a $2n$-by-$n$ multiplication - because our Karatsuba
multiplier described above only works over equal-width operands, this creates an inefficient multiplication.
So, we perform a second approximation in order to reduce the width of the numbers being multiplied -
$q'' = ⌊⌊ { AB } / 2^n ⌋ ⋅{c / 2^{n}}⌋$. To compute $q''$, we perform two multiplications - first we compute
$ AB $, and then we multiply the top $n$ bits of the result by $c$ (an $n+1$-digit number) and take
the top $n$ bits of the result.

Overall, for stage 1 of Barrett's Algorithm, we compute $q''$, and then compute $r' = AB - q''P$. We can show with
some bounding arguments that $0 ≤ q - q'' ≤ 3$, so we know that approximate remainder $r'$ is within 3 multiples of $P$
from the true remainder $r$.

### Stage 2: Fine Approximation
Suppose that the approximation from Stage 1 has an error of $e$, so $0 ≤ q - q'' ≤ e$. (Above, we showed
a coarse reduction scheme that gives $e=3$, but we can tune this using optimizations discussed below).

In the standard implementation of Barrett reduction, the coarse approximation stage is followed by a
fine approximation stage in which we compute $r' - mP$ for $ m∈[0,e] $ and pick the result that is within the
range $[0, P-1]$. As $e$ gets large, this naive implementation becomes very expensive, so we show an
optimized implementation based on BRAM lookups below.

This is the most basic form of Barrett reduction, but we extend it with further optimizations.

## LSB Multiplication

In the discussion above, the subtraction at the end of Stage 1 only requires the least significant
$n+2$ bits (because the error is at most $3P$). As a result, we can use a truncated LSB multiplier to
compute $q''P$ instead of a full multiplier. This follows from the Karatsuba multiplication formulation
by just dropping the high order term ($z_2$). Further, we can recursively apply this idea to build
an LSB-truncated Karatsuba multiplier.

## Approximate MSB Multiplication

In the discussion above, we only keep the $n$ most-significant bits of $⌊ { AB } / 2^n ⌋ ⋅c$. Instead of
using a full multiplier to perform this computation, we can use an approximate MSB-truncated multiplier
and propagate the error into the overall error bounds on the coarse reduction stage of Barrett reduction.

In particular, in the truncated MSB multiplier, we recursively drop the lowest order term ($z_0$) from
the Karatsuba formulation, keeping careful track of the error this propagates through the product. The more
aggressively we split the product (ie the wider the product $z_0$ that we drop), the more error is introduced into
the approximation.

For further reading, there are many thorough resources on Barrett reduction and truncated multipliers available on the internet.

## BRAM Reduction

From the MSB approximation, we essentially get a knob which lets us trade-off the coarseness of
Barrett reduction with the resource usage of its constituent multipliers. Even when pipelined, if $e$
is large, the fine reduction scheme presented above requires many stages of shifts and subtractions
to choose the final reduced remainder. Instead, we use a BRAM lookup to reduce this to a 2-stage pipeline that
can reduce a very wide error.

In particular, we design a module which can reduce any input $r'∈[0, {2^e}P)$ to an equivalent value modulo $P$ in the range
$[0, p)$ with just two subtraction stages, for any integer $e$.

We do this by precomputing and loading a ROM $R$ with $2^e$ entries. We set $R[0] = 0$. Then,
for $i≥1$, entry $R[i]$ holds the final $n$ bits of the largest multiple of $p$ that has $i-1$ as its $e$-bit
prefix when written with $e+n$ bits. In particular,

 $$R[i] = ⌊{(i-1) ⋅ 2^n} / {p} ⌋ (\mod 2^{n}) $$

Then, given an input $r'∈[0, {2^e}P)$ with $e+n$ bits, we can lookup its $e$-bit prefix in the ROM
and subtract the resulting value from the $n$-bit suffix of our input value:

$$ r'[n-1:0] - R[r'[e-1+n:n]] $$

(note that we only need to use the lower $n$ bits because we know what the higher bits are by construction). Then,
when the lookup index is nonzero, we have to invert the MSB of the signed result to get an unsigned reduction
$r''$ to the range $\[0,3p)$.

After this, we do one more subtraction stage where we just multiplex between $\{r'', r''-p, r''-2p\}$
to choose the final result.

This idea was inspired by work by [Langhammer and Pasca](https://dl.acm.org/doi/abs/10.1145/3431920.3439306).

## Multiplication by Constant

The LSB and Approximate MSB Multiplication routines above involve heavy
multiplication by constants. In our work, we represent the constant in
[non-adjacent form (NAF)](https://en.wikipedia.org/wiki/Non-adjacent_form) form.
If the constant has a hamming weight in NAF larger than a certain threshold,
we utilize DSP slices. Otherwise, it is implemented using long multiplication
with LUTs.

## Other Things We Tried

We experimented with several other things in implementing the field
multipliers. Here are some things that didn't work well enough to make it into
the final implementation:

**Hybrid LUT / Multipliers** In computing the `A * B`, we've solely relied on
DSP slices. This is suboptimal, since we use 2 slices of 26x17 multipliers just
to compute 22x22! We could use a hybrid of DSP and LUTs to perform the 22x22
multiplication to save 1 DSP per base case multiplier. However, we found our
primary bottleneck to largely be in LUT routing congestion, so we ended up
being more liberal in our DSP usage.

**Radix 3 Splitting** We experimented with radix-3 splitting (meaning splitting
$ x = 2^{2/3 W}x_2 + 2^{1/3 W}x_1 + x_0 $).  While it has slightly
lower latency, since it requires less levels, we found that it has a higher
resource usage. Given the point adder latency didn't matter too much, we didn't
investigate this further.
