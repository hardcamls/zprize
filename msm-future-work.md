---
layout: default
title: Future Work
category: msm
subcategory: design
---

# Future Work

## DDR Bandwidth
Our current design uses about 19.2 Gbps DDR bandwidth, which is about 15% of the
bandwidth available to a single DDR controller on the AWS F1 FPGA. There are 4
controllers in the AWS shell, so we are using about 3.75% of the overall DDR 
bandwidth available. We believe that we could make significant optimizations by 
using more bandwidth.

**Larger Buckets** We currently use 12-13 bit buckets in Pippenger's Algorithm
in order to fit all of the partial sums in URAM on on the FPGA. Further, we
iterate over all of the input points and scalars a single time, and compute all
of the windows in one pass. We think that making multiple passes over the points
and scalars and computing only a subset of the windows on each pass would allow us
to use larger bucket sizes and improve our end-to-end latency by 10-20%.

## Pippenger Bucket Sum Computation

**Redesign controller to natively accept scalars every clock cycle** The
current pippenger implementation instantiates 2 controllers that accepts
an input every 2 clock cycles to achieve full throughput. This is not terribly
inefficient, but does require the number of windows to be even to achieve
full throughput. With a single-cycle controller, we would immediately get a
5% performance improvement, as we would be able to use 19 windows instead of 20.

**Further reducing pipeline stall** We also think we could get rid of nearly
all bubbles in the pipeline if we presented the controller with two points per
cycle because the chances of both being a hazard are greatly reduced. We could
accomplish this by utilizing more DDR bandwidth, as noted above. We would
expect to gain an extra 4-5% performance with this change.

## Improving the Field Multiplication

**Exploiting Signed Multipliers** The DSP slices are capable of performing
$28 × 18$ _signed_ multiplication, which we currently just set the sign bit to 0.
The karatsuba ofman algorithm contains a subtraction in its intermediate
computation, which should be able to make use of the sign bit.

**Rectangular Karatsuba-Ofman** [These slides from Pasca et.
al.](http://www.bogdan-pasca.org/resources/talks/Karatsuba.pdf) describes
performing the karatsuba-ofman multiplication which fully utilizes non uniform
input widths of the multipliers in the DSP slice. The slides describe results
for $55 × 55$ multipliers, which we believe should be able to be extended to
much larger multipliers.

## Host Driver

**Optimizing final bucket sum** While using gmp was useful for
quick initial prototyping, a custom representation and implementation based on
exploiting the known bit widths (377 bits) of the curve is likely to be more
efficient.

**Parallelizing final bucket sum** [This work from
Xavier](https://eprint.iacr.org/2022/999) describes an algorithm to
parallelize the final bucket accumulation on the FPGA. This can be readapted on
the host using multiple threads.

## FPGA Technology
Our MSM solution was implemented on a previous-generation FPGA, as this is what 
AWS currently supports. We would like to experiment with the latest FPGA architectures
(such as Xilinx Versal Premium or Intel Agilex) to see if there are delay improvements
which would allow our design to operate at a higher frequency, or whether we could 
place and route another half-adder, which would afford our design greater parallelism.
