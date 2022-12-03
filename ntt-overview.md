---
layout: default
title: NTT Overview
category: ntt
subcategory: overview
---

# Number-Theoretic Transform (NTT)

This competition track required us to build an Inverse Number Theoretic
Transform (INTT) accelerator capable of performing transforms of size $2^24$.
INTTs are conceptually similar to the Fourier Transforms - working over a
finite field instead of complex numbers. For this project the finite field
contains values of size 64 bits modulo a so called [Solinas
prime](https://en.wikipedia.org/wiki/Solinas_prime) equal to $2^64 - 2^32 + 1$.

The platform tergetted is the Xilinx [Varium
C1100](https://www.xilinx.com/products/accelerators/varium/c1100.html)
accelerator card. The card contains Virtex UltrasScale+ FPGA with HBM2.

# Design overview

You can read more about our
[core INTT design](ntt-core.html) and how it is
[scaled up](ntt-performance-scaling.html) with shared controllers and wide
memory bus.

To achieve the required transform sizes we used the
[4-step](ntt-4step.html) algorithm and had to carefully consider
[bandwidth](ntt-bandwidth.html) limitations.

We present the
[performance](ntt-results.html) results for our
[top level Vitis design](ntt-top-level.html) and show how you can
[build](ntt-build-instructions.html) the design.

# Hardcaml on the Web

Configure our designs, download RTL and perform simulations all within your browser!

- [Core INTT design](apps/ntt/ntt-core-app-with-rams.html) which includes the IO RAMs, datapath and controller
- [Top level design as a Vitis kernel](apps/ntt/ntt-vitis-top-app.html) which performs the full 4-step algorithm

# Code structure

The code is built from a couple of libraries within our [submission repository](https://github.com/fyquah/hardcaml_zprize).

- [`Hardcaml_ntt`](https://github.com/fyquah/hardcaml_zprize/blob/master/libs/hardcaml_ntt) ([source code docs](odoc/zprize/Hardcaml_ntt/index.html))
- [`Zprize_ntt`](https://github.com/fyquah/hardcaml_zprize/blob/master/zprize/ntt) ([source code docs](odoc/zprize/Zprize_ntt/index.html))

The `Hardcaml_ntt` library provides the base implementation of the NTT core and includes a software model and various unit tests.

`Zprize_ntt` contains the code for both the top level
[Hardcaml INTT kernel](https://github.com/fyquah/hardcaml_zprize/tree/master/zprize/ntt/hardcaml/src) and
[tests](https://github.com/fyquah/hardcaml_zprize/tree/master/zprize/ntt/hardcaml/test) , the
[C++ HLS DMA kernel](https://github.com/fyquah/hardcaml_zprize/tree/master/zprize/ntt/fpga/common),
[host benchmarking software](https://github.com/fyquah/hardcaml_zprize/tree/master/zprize/ntt/host) and
[build scripts](https://github.com/fyquah/hardcaml_zprize/tree/master/zprize/ntt/fpga).

