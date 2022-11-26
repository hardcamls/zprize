---
layout: default
title: Implementation Details
---

# Implementation Details

Our implementation targets a AWS EC2 f1.2xlarge instance. This instance
contains a single VU9P part. We have utilized the [aws-fpga Vitis
flow](https://github.com/aws/aws-fpga/blob/master/Vitis/README.md) in our
hardware design and the [Xilinx Run Time (XRT)](https://github.com/Xilinx/XRT)
in our host code to interface with the driver.

## High-Level Implementation Overview

![](/images/msm-block-diagram-new.png)

- Memory Access Blocks (written with HLS)
- IO transformation blocks (written in Hardcaml)
- MSM block to compute pippenger bucket sums (written in Hardcaml,
  discussed in detail in other sections)
- C++ Host Driver (Discussed in detail in a dedicated host driver section)

## Memory Access Blocks

The HLS blocks (`krnl_mm2s` and `krnl_s2mm`) are used to interface with the AXI
master interface and transform them to/from AXI streams. We have two separate
HLS kernels accessing the same DDR bank for the memory region of affine points
and the loaded scalars. Using HLS blocks for these simple tasks is a massive
productivity boost:

- AXI Streams are much easier to work with then raw full-fledged AXI master
ports in our Hardcaml blocks that does the actual work
- The HLS kernels have a predefined API for communication with the host drivers

In our implementation, all the memory access kernels accesses DDR0. We don't
observe any contention in our memory access, because:

- Our memory access pattern is streaming friendly
- Our computation is nowhere near memory bound

Conveniently, the AWS shell has a memory controller built-in, so we didn't
need any additional resources for the memory controller.

## IO Transformation Blocks

The memory access blocks yields output of 512-bits a clock cycle, but

- The affine points are $377 * 3$ bits each
- The scalars are 253 bit each
- The bucket sums are $377 * 4$ bits each

The `merge_axi_stream` block does two things:

- Convert the 512-bit axi stream into a stream of scalars and affine points
- Aligns the scalar and affine point streams to be available at same clock
  cycle on the output

The `msm_result_to_host` block fits the stream of bucket running sum points
into 512-bit words in nice 64-bit word alligned order.

## Tricks to Improve Results

Our design uses up a lot of the FPGA resources. Operating at a clock rate
at the edge of the device's capability is challenging, here are some tricks
that we have used to get good results.

### Targetting higher frequency

The vitis linker config file allows us to easily specify a target frequency
to compile our design at. This makes it very convenient to experiment with
targetting various clock frequencies. In our submission, we set this number
as high as the router can reasonably take (which is ~280MHz).

A nice feature of the vitis linker is that it automatically downclocks the
design when it fails to meet timing closure. This allows us to target higher
frequencies than we expect, and still have a working design after a long
12-hour build.

In our submission, we used a build that targets 280MHz, but got downclocked to
278MHz.

Note that the choice of frequency affects the implementation results! Notably,
targetting 278MHz directly might not have delivered the same result.

### Vivado Implementation Strategies

We experimented with various Vivado implementation strategies. While they
tend to be design specific, we have found that the
`Congestion_SSI_spreadLogic_high` tend to have delivered better results. This
makes sense, our design

This is achieved with the following line in our linker script.

```
[vivado]
prop=run.impl_1.STRATEGY=Congestion_SSI_SpreadLogic_high
```

### Not Enabling Retiming

We have empirically experimented with Synthesis Retiming by adding
`set_param synth.elaboration.rodinMoreOptions "rt::set_parameter synRetiming true"`
in our pre synthesis hooks. Surprisingly, this has consistently made our
results worse! ($F_{max}$ degrades from ~250MHZ to ~125MHZ!). We did not
investigate why. We hypothesize that this could be due to presence of a lot of
register->register paths in our design dedicated for SLR crossing which synth
retiming tries to insert combinational logic into, damaging routing results.

Needless to say, we _did not_ include synth retiming as part of our submission!

### SLR Partitioning

Modern FPGAs are really several dies with limited interconnect resources between
dies. Xilinx refers to these dies as [Super Logic Regions
(SLRs)](https://docs.xilinx.com/r/2021.2-English/ug949-vivado-design-methodology/Super-Logic-Region-SLR)

The device our work targets contains 3 SLRs. There're interconnects at
SLR0<->SLR1 and SLR1<->SLR2.

In our design, we've added a vivado properties to the vitis linker config file
`prop=run.impl_1.STEPS.PLACE_DESIGN.TCL.PRE=pre_place.tcl`,with the contents of
`pre_place.tcl` being:

```
add_cells_to_pblock pblock_dynamic_SLR0 [get_cells -hierarchical *SLR0*]
add_cells_to_pblock pblock_dynamic_SLR1 [get_cells -hierarchical *SLR1*]
add_cells_to_pblock pblock_dynamic_SLR2 [get_cells -hierarchical *SLR2*]
```
