---
layout: default
title: FPGA top level design
---

# Top level Hardcaml design

The [top level Hardcaml design](https://github.com/fyquah/hardcaml_zprize/blob/master/zprize/ntt/hardcaml/src/top.ml) 
instantiates the [parallel INTT cores](ntt-performance-scaling.html) 
along with statemachines to sequence memory reads and writes and a transposer module.

<img src="images/parallel-ntt-top-level.png" width="70%">

The memory sequencers work in conjunction with a C++ HLS kernel to move data from memory
to the internal address space of the INTT cores and back again.

The transposer module is used to flip incoming data so it can be read and written
in parallel to the internal cores.  When we are reading the data for multiple rows during
the 2nd pass of the 4step algorith we get 8 coefficients per cycle which need to be routed
to a single core.  However, each core can only accept 1 coefficient per cycle.

The transposer will read 8 coefficients per cycle and hold them.  Once enough rows are read, it
will output a column of 8 coefficients per cycle which can be loaded into a set of INTT input
RAMs.

# Vtiis kernels

The top level FPGA design is built using the Xilinx Vitis design flow.  It consists
of two kernels - the top level hardcaml design, and a
[C++ HLS kernel](https://github.com/fyquah/hardcaml_zprize/blob/master/zprize/ntt/fpga/common/krnl_controller_normal_layout.cpp)
to interface with PCIe and HBM2 memory.

The C++ kernel coordinates the transfer of data ...

1. ... from the host to HBM2 memory.
2. ... from HBM2 memory back to the host.
3. ... from HBM2 into the Hardcaml INTT kernel
4. ... from the INTT kernel into HBM

It is aware of the 2 passes of the 4step algorithm and works in conjunction with the Hardcaml
memory sequencers.

<img src="images/ntt-top-level.png" width="70%">>

## Build and Testing Instructions

Please refer to [this page](ntt_build_instructions).