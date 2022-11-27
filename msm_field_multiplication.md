---
layout: default
title: optimising_msm
---

# Performing Field Multiplication

A key operation in is field multiplication in a prime field, ie: computing
`C = A * B mod P`, where P is a 377-bit prime number, and `A` and `B` are
both elements of the prime field (ie: `0 <= A < P`, A is an unsigned integer).

Our field multiplication has several requirements
- it's fully pipelined - in other words, it has a throughput of one per cycle
- $P$ is known at compile time
- $A$ and $B$ are known at runtime

## Barrett Reduction

<!-- CR fyquah: Something something write this -->

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

## LSB Multiplication

<!-- CR fyquah: Write this -->

## Approx MSB Multiplication

<!-- CR fyquah: Write this -->

## Multiplication by Constant

The LSB and Approx MSB Multiplication routines above invovles heavy
multiplication by constants. In our work, we represent the constant in
[non-adjacent form (NAF)](https://en.wikipedia.org/wiki/Non-adjacent_form) form.
If the constant has a hamming weight in NAF larger than a certain threshold,
we utilize DSP slices. Otherwise, it is implemented using long multiplication
with LUTs.

## Other Things We Tried

We experimented with several other things in implementing the field
multipliers. Here are somethings that didn't work well enough to make it into
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

## Ideas for Improvements

**Exploiting Signed Multipliers** The DSP slices are capable of performing
$28 × 18$ _signed_ multiplication, which we currently just set the sign bit to 0.
The karatsuba ofman algorithm contains a subtraction in its intermediate
computation, which should be able to make use of the sign bit.

**Rectangular Karatsuba-Ofman** [These slides](http://www.bogdan-pasca.org/resources/talks/Karatsuba.pdf)
from Pasca et. al. describes performing the karatsuba-ofman multiplication
which fully utilizes non uniform input widths of the multipliers in the DSP
slice. The slides describes results for $55 × 55$ multipliers, which we believe
should be able to be extended to much larger multipliers.
