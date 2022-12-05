---
layout: default
title: NTT Overview
category: ntt
subcategory: overview
---

# Number-Theoretic Transform (NTT)

This competition track required us to build a Number Theoretic Transform (NTT)
accelerator capable of performing transforms of size $2^24$.  NTTs are
conceptually similar to the Fourier Transforms - working over a finite field
instead of complex numbers. For this project, the finite field contains values
of size 64 bits modulo a so called [Solinas
prime](https://en.wikipedia.org/wiki/Solinas_prime) equal to $2^64 - 2^32 + 1$.

The mathematical formulation of the NTT is as the following:

$$X_{i} = ∑↙{j=0}↖{N-1} x_{j} w^{ij} (mod P)$$

where $N$ is the size of the input vector $x$, $P$ is the solanis prime
and $w$ is the $N$th [root of unity](https://en.wikipedia.org/wiki/Discrete_Fourier_transform_over_a_ring#Number-theoretic_transform).
$X_{i}$ is defined for $0 ≤ i < N$.

The main design challenge is that such large transforms cannot fit within a
single FPGA's on-chip RAM resources, so we need to make efficient use of large
external DRAM resources.

The platform targeted is the Xilinx [Varium
C1100](https://www.xilinx.com/products/accelerators/varium/c1100.html)
accelerator card. The card contains a Virtex UltrasScale+ FPGA with HBM2.

# Design overview

Our work is built around the 4-step algorithm to break down a large NTT into
much smaller NTTs. The smaller NTTs are computed using the well-known
decimation in time
[Cooley-Tukey FFT
algorithm](https://en.wikipedia.org/wiki/Cooley–Tukey_FFT_algorithm).  The
following pages discusses the algorithms and design considerations:

- [4-step](ntt-4step.html) details the 4-step algorithm
- [Bandwidth Considerations](ntt-bandwidth.html)

You can read more about our FPGA implementation in the following pages:

- [core NTT design](ntt-core.html)
- [scaling Up performance with shared controllers and a wide memory bus](ntt-performance-scaling.html)
- [top level Vitis design](ntt-top-level.html)

We present the [performance](ntt-results.html) results for our design and show
how you can [build](ntt-build-instructions.html) the design.

# Hardcaml on the Web

Configure our designs, download RTL and perform simulations all within your browser:

- [Core NTT design](apps/ntt/ntt-core-with-rams-app) which includes the IO RAMs, datapath and controller
- [Top level design as a Vitis kernel](apps/ntt/ntt-vitis-top-app) which performs the full 4-step algorithm

# Code structure

The code is built from a couple of libraries within our [submission repository](https://github.com/fyquah/hardcaml_zprize):

- [`Hardcaml_ntt`](https://github.com/fyquah/hardcaml_zprize/blob/master/libs/hardcaml_ntt) ([source code docs](odoc/zprize/Hardcaml_ntt/index.html))
- [`Zprize_ntt`](https://github.com/fyquah/hardcaml_zprize/blob/master/zprize/ntt) ([source code docs](odoc/zprize/Zprize_ntt/index.html))

The `Hardcaml_ntt` library provides the base implementation of the NTT core and includes a software model and various unit tests.

`Zprize_ntt` contains the code for both the top-level
[Hardcaml NTT kernel](https://github.com/fyquah/hardcaml_zprize/tree/master/zprize/ntt/hardcaml/src) and
[tests](https://github.com/fyquah/hardcaml_zprize/tree/master/zprize/ntt/hardcaml/test), the
[C++ HLS DMA kernel](https://github.com/fyquah/hardcaml_zprize/tree/master/zprize/ntt/fpga/common),
[host benchmarking software](https://github.com/fyquah/hardcaml_zprize/tree/master/zprize/ntt/host), and
[build scripts](https://github.com/fyquah/hardcaml_zprize/tree/master/zprize/ntt/fpga).

