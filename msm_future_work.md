---
layout: default
title: Future Work
---

# Future Work

## Bucket Sum Computation

## Improving the Field Multiplication
>>>>>>> refs/remotes/origin/master

**Exploiting Signed Multipliers** The DSP slices are capable of performing
$28 × 18$ _signed_ multiplication, which we currently just set the sign bit to 0.
The karatsuba ofman algorithm contains a subtraction in its intermediate
computation, which should be able to make use of the sign bit.

**Rectangular Karatsuba-Ofman** [These slides](http://www.bogdan-pasca.org/resources/talks/Karatsuba.pdf)
from Pasca et. al. describes performing the karatsuba-ofman multiplication
which fully utilizes non uniform input widths of the multipliers in the DSP
slice. The slides describes results for $55 × 55$ multipliers, which we believe
should be able to be extended to much larger multipliers.

## Host Driver

**Optimizing final bucket sum accumulation** While using gmp was useful for
quick initial prototyping, a custom representation and implementation based on
exploiting the known bit widths (377 bits) of the curve is is likely to be more
efficient.

**Parallelizing final bucket sum** [This work](https://eprint.iacr.org/2022/999.pdf)
from Xavier et. al. describes an algorithm to parallelize the final bucket
accumulation on the FPGA. This can be readapted on the host using multiple
threads.
>>>>>>> refs/remotes/origin/master
