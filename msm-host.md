---
layout: default
title: Host Driver
category: msm
subcategory: design
---

# Host Driver Software

Our host driver performs the following preprocessing ahead of any evaluations
in `msm_init`:

- Transform the affine points from Weierstrass form into our internal affine
  point format based on scaled twisted edwards curves (See the page on [mixed
  point addition](msm-mixed-point-addition-with-precomputation.html) for the
  formulae of the transformation.)
- Transfer the preprocessed points into the FPGA

It performs the following when evaluating MSMs in `msm_mult`:

- Transfers scalars to the DDR
- Startup Xilinx Vitis kernels to transfer (scalar & points) from DDR to the
  MSM evaluation blocks for performing bucket sums
- Startup Xilinx Vitis kernels to transfer pippenger bucket sums results back
  to the host
- Perform final bucket aggregation

The host driver interleave most of the CPU work with the FPGA work to reduce
total latency when evaluating a batch of multiple MSMs:

- Start the MSM evaluation before transfering all the scalars into the host.
- Transfer scalars for the next msm evaluation while the first evaluation has
  not completed.
- Evaluate the next MSM's bucket sums on the FPGA while compute the current
  MSM's final bucket aggregation on the host.

Our host driver expects the prime field elements to be in [Montgomery
form](https://en.wikipedia.org/wiki/Montgomery_modular_multiplication), as our
competition test harness interfaces with the
[Arkworks](https://github.com/arkworks-rs) library which internally represents
field elements in this form. This representation incurs a ~10us penalty per MSM
evaluation, which is insignificant for large MSMs.

Our host driver uses the Xilinx XRT library with openCL for host to/from FPGA
communication, and gmp for any on-host computation. Code for our host driver is
available
[here](https://github.com/fyquah/hardcaml_zprize/blob/master/zprize/msm_pippenger/host/driver/driver.cpp).
