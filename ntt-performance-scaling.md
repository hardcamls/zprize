---
layout: default
title: Performance Scaling
category: ntt
subcategory: design
---

# Performance Scaling

## 8 parallel cores

The [4-step algorithm](ntt-4step.html) provides an obvious way to scale up performance.
A large transform is broken up into thousands of smaller NTT transforms which may be
performed in parallel.

This is the approach taken in our core.  The first level of scaling is implemented in the
[parallel cores](https://github.com/fyquah/hardcaml_zprize/blob/master/libs/hardcaml_ntt/src/parallel_cores.ml)
module which conceptually groups 8 NTT cores together.  The actual design is slightly more
optimal in that it shares a single controller module for all 8 data paths and related memories.

The grouping of 8 cores was chosen as this matches our memory bus width.  Each core has a 64 bit
input and output bus for loading and storing coefficients.  $8 x 64 = 512$ which is the required
width.

## Multi-Parallel Cores

The [multi-parallel cores](https://github.com/fyquah/hardcaml_zprize/blob/master/libs/hardcaml_ntt/src/multi_parallel_cores.ml)
module instantiates multiple parallel cores further increasing parallelism.

Each block of 8 parallel cores shares the memory bus at this level of the design so it must be
decoder/multiplexed into a unified address space.

A simplification of the design made here is to only allow scaling at powers of 2 to simplify
internal address decoding.  This requirement limits our performance a little as we could
match memory bandwidth or area constraints more accurately if we could scale up arbitrarily.

## 4-step controller

The [4-step controller](https://github.com/fyquah/hardcaml_zprize/blob/master/libs/hardcaml_ntt/src/four_step_controller.ml)
module sequences a single pass of the 4 step algorithm.  For a transform of size $2^24$ we
must perform $2^12 = 4096$ NTTs.  With, say, 32 cores we need to iterate $4096/32 = 128$ times
per pass.

This module controls that iteration and sequences the memory access steps in parallel with the
NTT transforms.

The overall performance of the design, assuming memory can be accessed quickly enough, is bound
by the number of require iterations plus an initial memory load and final memory store operation.
