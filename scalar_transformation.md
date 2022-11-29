---
layout: default
title: Scalar Transformation
---

# Scalar Transformation

In order to reduce our overall latency and UltraRAM usage, we transform all of the input scalars to a
[signed-digit representation](https://en.wikipedia.org/wiki/Signed-digit_representation). We perform
this entire transformation on the FPGA as a pipelined precomputation before sending the scalars to the
controller.

The main transform currently implemented transforms the input scalar from unsigned digits
in the range $[0,2^b-1]$ to signed digits in the range $[-2^{b-1}, 2^{b-1}-1]$.

It does this as follows: suppose we have a B-bit scalar $k$, split into $N$
windows of size $b_i$, where $∑↙{i=0}↖{N-1}{b_i} = B$. Then, letting
$o_i = ∑↙{j=0}↖{i-1}{b_i}$ be the offsets of each digit, we can write

$$ k = ∑↙{i=0}↖{N-1}{2^{o_i}d_i},\; d_i∈[0,2^{b_i}-1]\;∀i  $$

as a normal unsigned representation of $k$ (derived by just directly windowing the bits in its
binary representation).

Then, we perform the following iterative transform from $i = 0$ to $N-2$.

$$ 
If d_i ≥ 2^{b_i-1}: (d_i, d_{i+1}) → (d_i - 2^{b_i}, d_{i+1} + 1)
$$

After performing this transform, digits $d_i∈[-2^{b_i-1}, 2^{b_i-1}-1]$ for $i\in[0,N-2]$.

The downstream point adder can exploit this new digit base because point negation is extremely cheap (on the Twisted Edwards
affine space, it just corresponds to negating the x-coordinate). So, for all but the final window,
we can halve the number of buckets and use point subtraction for all the negative buckets.

The module implements this transform as a fully unrolled (N-1)-stage pipeline, with optional skid buffers
in order to cut combinational ready signal paths. It is designed in a modular way so that the 
overall scalar transformation can be extended to include many further transforms using other 
scalars (i.e. 2, 3, etc.), if point multiples were precomputed and loaded in the FPGA.
