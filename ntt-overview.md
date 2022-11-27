---
layout: default
title: NTT overview
---

# Code structure

The code is built from a couple of libraries within our submission repository.

1. [Hardcaml_ntt](https://github.com/fyquah/hardcaml_zprize/blob/master/libs/hardcaml_ntt) ([source code docs](odoc/zprize/Hardcaml_ntt/index.html))
2. [Zprize_ntt](https://github.com/fyquah/hardcaml_zprize/blob/master/zprize/ntt) ([source code docs](odoc/zprize/Zprize_ntt/index.html))

The `Hardcaml_ntt` library provides the base implementation of the NTT core and includes a software model and various unit tests.

`Zprize_ntt` contains the code for both the top level 
[Hardcaml INNT kernel](https://github.com/fyquah/hardcaml_zprize/tree/master/zprize/ntt/hardcaml/src) and
[tests](https://github.com/fyquah/hardcaml_zprize/tree/master/zprize/ntt/hardcaml/test) , the
[C++ HLS DMA kernel](https://github.com/fyquah/hardcaml_zprize/tree/master/zprize/ntt/fpga/common),
[host benchmarking software](https://github.com/fyquah/hardcaml_zprize/tree/master/zprize/ntt/host) and
[build scripts](https://github.com/fyquah/hardcaml_zprize/tree/master/zprize/ntt/fpga).

# Design overviews

You can read more about our
[core INNT design](ntt-core.html) and  how it is
[scaled up](ntt-performance-scaling.html) with shared controllers and wide
memory bus.

To achieve the required transform sizes we used the 
[4-step](ntt-4step.html) algorithm and had to carefully consider 
[bandwidth](ntt-bandwidth.html) limitations.

We present the
[performance](ntt-results.html) results for our 
[top level Vitis design](ntt-top-level.html) and show how you can 
[build](ntt-build-instructions.html) the design.
