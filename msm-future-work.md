---
layout: default
title: Future Work
category: msm
subcategory: design
---

# Future Work

## Pippenger Bucket Sum Computation

**Redesign controller to natively accept scalars every clock cycle** The
current pippenger implementation instantiates 2 controllers that accepts
an input every 2 clock cycles to achieve full throughput. This is not terribly
inefficients, but does requires the number of windows to be even to acheieve
full throughput.

**Further reducing pipeline stall** We also think we could get rid of nearly
all bubbles in the pipeline if we presented the controller with two points per
cycle.  The chances of both being a hazard are greatly reduced.  We would
expect to gain an extra 4-5% performance with this change.


## Improving the Field Multiplication

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

**Parallelizing final bucket sum** [This work form
Xavier](https://eprint.iacr.org/2022/999.pdf) describes an algorithm to
parallelize the final bucket accumulation on the FPGA. This can be readapted on
the host using multiple threads.
