---
layout: default
title: 4 Step Algorithm
category: ntt
subcategory: design
---

# 4 step algorithm

The core design limits us to transform sizes which can fit within on-chip FPGA RAM resources.
To break this limit we use the well known 4-step algorithm as described in
[this paper](https://arxiv.org/pdf/2011.11524.pdf).  An OCaml reference implementation is provided
in our [repository](https://github.com/fyquah/hardcaml_zprize/blob/master/libs/hardcaml_ntt/src/reference_model.ml)

The idea is to break the large transform into lots of smaller transforms.  Let's consider our
target transform size of $2^24$.  We first reformulate the input data as a $2^12 x 2^12$ matrix in row major order.

The following steps are then performed.

1. Perform $2^12$ NTTs on each column
2. Multiply each element of the matrix at location $(i,j)$ by $ω^(i.j)$, where $ω$ is the appropriate
   root of unity of the transform size.
3. Perform $2^12$ NTTs on each row
4. Transpose the result

The required NTT transform can now easily fit within on-chip FPGA RAM resources, so long as we can
store the complete matrix in external memory and access it efficiently.

## Performance

Using the [Coole-Tukey FFT
algorithm](https://en.wikipedia.org/wiki/Cooley–Tukey_FFT_algorithm), a
transform of size $2^24$ requires $2^24 log_{2} 2^24 = 402,653,184$ operations.

The 4-step algorithm performs smaller $2 . 2^12$ NTT transforms, each of size
$2^12$. This works out to the same number of $402,653,184$ operations as using
Coole-Tukey algorithm. However, we must add to this a further $2 . 2^24$
operations to perform the scaling operation (the scaling requires 2
multiplications - one to scale the coefficient, and the other to update the scaling factor).

The following table gives the total operations and overhead for a few transform sizes.

| $log_{2} N$ NTT | Full transform operations | 4-step operations | Overhead % |
|------------------|---------------------------|-------------------|------------|
| 18 | 4718592    | 5242880    | 11.1    |
| 20 | 20971520   |  23068672  | 10.0    |
| 22 | 92274688   | 100663296  | 9.0     |
| 24 | 402653184  | 436207616  | 8.3     |
| 26 | 1744830464 | 1879048192 | 7.7     |
| 28 | 7516192768 | 8053063680 | 7.1     |

## Transposition

The 4-step algorithm talks about row and column transforms and a final
transposition step.  This is not actually performed by the hardware design.
Rather data is read and written from the matrix in memory as follows

1. Read columns
2. Write columns
3. Read rows
4. Write columns

Reading a single column would be very inefficient for DDR style dynamic memories.  Fortunately as we
[scale up](ntt-performance-scaling.html) the design for performance we can read multiple columns
at a time. We will also show a
[data reorganisation approach](ntt-bandwidth.html) which leads to very efficient memory
access at the cost of reordering the coefficients in the input matrix.
