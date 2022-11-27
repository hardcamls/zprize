---
layout: default
title: Ntt results
---

# Experiments

To evaluate our results, we perform 2 sets of experiments.

## Normal-layout Builds

These are builds where the input and output vector to perform NTT on is laid out
linearly in HBM (ie: the host doesn't perform any pre/post-processing). We run
experiments with running the 8-core, 16-core, 32-core and 64-core variants,
yeilding different levels of parallelism.

## Optimized-layout Builds

As discussed [here](ntt-bandwidth.html), our performance is significantly
bound by bandwidth. We conduct 2 builds (32-core and 64-core variant) with a
simple data-rearrangement preprocessing step such that the core can stream data
in 2048-4096 byte bursts.

# Results For Zprize

We have tested our design and ran builds on a 6-core
Intel(R) Core(TM) i5-9600K CPU @ 3.70GHz machine with
[Ubuntu 22.04 LTS (GNU/Linux 5.15.0-48-generic x86_64)]. We did not use
any special kernel flags / boot parameters to obtain our results. We ran
our designs using the Vitis platform Xilinx has provided for the Varium C1100
card. The platform takes up some resources on the FPGA and comes with PCIe gen3
x4 support

We measured our latency by taking the FPGA-only evaluation latency across 200
NTT runs. Power was measured by sampling `xbutil examaine --report electrical
--device <device-pcie-id>` 10 times during the latency benchmark.

In this normal layout build, we do not perform any preprocessing or
post-processing. Hence, latency below includes only the FPGA NTT evaluation
latency.

## Latency, Power and Resource Utilization

The table below depicits our results for various builds

|   Build | Latency(s) | Power(W) | LUTS   | Registers |  DSP | BRAM36 | URAM  |
|---------|------------|----------|--------|-----------|------|--------|-------|
|  8 core |     0.2315 |    16.97 | 107291 |    141006 |  260 |    162 |   48  |
| 16 core |     0.1238 |    18.19 | 126422 |    156149 |  512 |    162 |   96  |
| 32 core |     0.0691 |    21.13 | 166488 |    184436 | 1028 |    162 |   192 |
| 64 core |     0.0450 |    27.70 | 265523 |    246385 | 2052 |    162 |   384 |


Here are the available resources on the FPGA. Note that as we are building on
top of a Vitis platform, it imposes a non-trivial fixed-cost that we don't
control. The number is reported as "fixed" in the post_route_utilization.rpt

| Resource  | Available on FPGA | Used by Vitis Platform |
|-----------|-------------------|------------------------|
|      LUTS |            870720 |                  62191 |
| Registers |           1743360 |                  81502 |
|       DSP |              5952 |                      4 |
|    BRAM36 |              1344 |                      0 |
|      URAM |               640 |                      0 |

## FOM Measurement

Here are our FOM numbers. As detailed in the evaluation criteria provided by Zprize,
FOM is computed as $latency * sqrt(Power) * {Unorm}$. Note that `N_pipe = 1`
for our design, since it can only support 1 evaluation at a time.

Latency and Power is used as report above in seconds and Watts respectively.
We calculate $Unorm = U(LUTS) + U(Registers) + U(DSP) + U(BRAM) + U(URAM)$.
The max possible value of `Unorm` is hence 4.0, since $0 <= U(...) < 1.0$

These are FOM numbers assuming we don't include the platform (aka fixed resources)
in our utlization

|  Build  |  LUTs  |  Registers |    DSP |   BRAM |   URAM | U_norm |  FOM   |
|---------|--------|------------|--------|--------|--------|-----------------|
| 8-core  | 0.0518 |     0.0341 | 0.0430 | 0.1205 | 0.0750 | 0.3245 | 0.3095 |
| 16-core | 0.0749 |     0.0428 | 0.0860 | 0.1205 | 0.1500 | 0.4743 | 0.2505 |
| 32-core | 0.1198 |     0.0590 | 0.1720 | 0.1205 | 0.3000 | 0.7714 | 0.2451 |
| 64-core | 0.2335 |     0.0946 | 0.3441 | 0.1205 | 0.6000 | 1.3927 | 0.3301 |

Our best-build for the evaluation criteria is the 32-core variant, with a __FOM of 0.2451__.

The following FOM numbers are assuming we have to include the Vitis platform
resources as part of our utilization. To stress this fact -- we don't think
those resources should be considered as part of the evaluation!


|  Build  |   LUTs |  Registers |    DSP |   BRAM |   URAM | U_norm |  FOM   |
|---------|--------|------------|--------|--------|--------|--------|--------|
| 8-core  | 0.1232 |     0.0809 | 0.0437 | 0.1205 | 0.0750 | 0.4433 | 0.4229 |
| 16-core | 0.1463 |     0.0896 | 0.0867 | 0.1205 | 0.1500 | 0.5931 | 0.3132 |
| 32-core | 0.1912 |     0.1058 | 0.1727 | 0.1205 | 0.3000 | 0.8903 | 0.2829 |
| 64-core | 0.3049 |     0.1413 | 0.3448 | 0.1205 | 0.6000 | 1.5116 | 0.3583 |


Using these criteria, our best build is also the 32-core variant with a FOM of
0.2829

## Result from Optimized-Layout Builds

Here is a detailed breakdown of a runtime sample of an optimized 64-core build:
(The power and utilization is similar to the normal-layout builds)


__Breakdown of a 2^24 optimized-layout 64-core evaluation__

|               Task                     |   Time  |
|----------------------------------------|---------|
| Preprocessing data rearrangement       | 0.0213s |
| Copying input points to device         | 0.0414s |
| Doing Actual NTT work                  | 0.0267s (vs 0.0450s in normal layout) |
| Copying final result to host           | 0.0552s |
| Copy from internal page-aligned buffer | 0.0231s |
| __Evaluate NTT__                       | __0.1680s__ |

__Breakdown of a 2^24 optimized-layout 32-core evaluation__

|               Task                     |   Time  |
|----------------------------------------|---------|
| Preprocessing data rearrangement       | 0.0217s |
| Copying input points to device         | 0.0416s |
| Doing Actual NTT work                  | 0.0349s (vs 0.0691s in normal layout) |
| Copying final result to host           | 0.0554s |
| Copy from internal page-aligned buffer | 0.0228s |
| __Evaluate NTT__                       | __0.1770s__ |


By rearranging the data in a much more memory-friendly layout, our NTT
evaluation time drops significantly compared to those of a 64-core build in
a normal build (0.0267s vs 0.0450s). This comes at the cost of the host doing
some data rearrangement.

The bottleneck of our evaluation clear lie in the host and PCIe latency in
this result, both of which can be solved pretty easily:

- `preprocessing + postprocessing > latency` - We can run the preprocessing
  and post-processing in separate threads. We can setup the input and output
  buffers such such that we don't run into cache coherency issues. We can also
  mask some of the preprocessing latency with PCIe latency.
- `The PCIe latency is larger than the NTT evaluation` - This is because the
  vitis platform we are using only supports PCIe x4. With PCIe x16, we would have
  4 times the bandwidth and side-step this problem.

In practice, we believe this is the more scalable design that can achieve
low-latency and high-throughput, at the cost of the host machine doing some
data rearrangement.
