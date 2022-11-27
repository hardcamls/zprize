---
layout: default
title: Host Driver
---

# Host Driver

Our host driver performs the following preprocessing ahead of any evaluations
in `msm_init`

- Transform the affine points from Weistrass form into our internal affine
  point format based on scaled twisted edwards curves (See the page on [mixed
  point addition](msm_mixed_point_addition_with_precomputation.html) for the
  formulae of the transformation.)
- Transfer the preprocessed points into the FPGA

It performs the following when evaluating MSMs in `msm_mult`:

- Transfers scalars to the DDR of the FPGA
- Startup Xilinx Vitis kernels to transfer DDR contents to the MSM evaluation
  blocks for performing bucket sums
- Transfers pippenger bucket sums results back to the host
- Perform final bucket accumulation

We heavily interleave some of the CPU work with the FPGA work to reduce total
latency when evaluating a batch of multiple MSMs, namely:

- Start the MSM evaluation before transfering all the scalars into the host.
- Transfer scalars for the next msm evaluation while the first evaluation has
  not completed.
- Evaluate the next MSM's bucket sums on the FPGA while compute the current
  MSM's final bucket accumulation on the host.

Our host driver expects the prime field elements to in [Montgomery
form](https://en.wikipedia.org/wiki/Montgomery_modular_multiplication), as our
competition test harness interfaces with the
[Arkworks](https://github.com/arkworks-rs) library which internally represents
field elements as such.

Our implementation internally uses barrett reduction, so we pay some additional
cost to convert the final result back to Montgomery form during MSM evaluation.
In practice this means we likely pay some extra cost. We measured this to be
~10us per MSM evaluation, which is insignificant for large MSM.

Our host driver uses the Xilinx XRT library with openCL for host to/from FPGA
communication, and gmp for any on-host computation.

Code for our host driver is available
[here](https://github.com/fyquah/hardcaml_zprize/blob/master/zprize/msm_pippenger/host/driver/driver.cpp). 

## Build Instructions

NOTE: There's probably a bunch of `gmp` specific optimizations we can do (https://gmplib.org/manual/Installing-GMP).

```
source ~/aws-fpga/vitis_setup.sh
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make -j
```

## clang-format
```
find driver naive_driver msm_compute -iname *.h -o -iname *.cpp | xargs clang-format --style=Google -i
```
