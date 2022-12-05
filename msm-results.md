---
layout: default
title: Results
category: msm
subcategory: design
---

# Results

As per the ZPrize competition spec, we use an AWS f1.2xlarge instance,
targeting the BLS12-377 curve with the G1 subgroup-generator. This AWS
instance contains a Intel Xeon E5-2686 v4 Processor (2.3 GHz (base) and 2.7 GHz
(turbo)) and a UltraScale+ VU9P FPGA.

We achieved a performance of **20.33s** $2^26$ MSMs with a batch size of 4.

<!-- CR fyquah: If have time, benchmark more configurations / MSM sizes -->

## Breakdown of Individual Steps

In our actual work, we masked a memory transfer latency and host post
processing latency with the bucket aggregation computation on the FPGA.

| Task                                         |  Time(s)     |
|----------------------------------------------|--------------|
| Memcpy 2^26 scalars to special memory region |     0.289 |
| Transferring 2^26 scalars to FPGA            |     0.198 |
| Computing bucket aggregation on FPGA         |     4.968 |
| Copying bucket values back from FPGA         |     0.001 |
| Doing on-host postprocessing                 |     0.470 |
|----------------------------------------------|--------------|
| **Serialized total time per MSM**                 |   **5.927** |

## Resource Utilization

The AWS shell uses roughly 20% of the resources available on the FPGA. We tuned
our MSM implementation to use the remaining resources as much as possible while
still being able to successfully route in Vivado.

An interesting observation is our CLB usage usage on SLR2 (the SLR that does not
contain any of the AWS shell) is almost double those of the LUT usage! This
is likely due to high congestion in our design.

|----------------------------|--------|--------|--------|--------|--------|--------|
|          Site Type         |  SLR0  |  SLR1  |  SLR2  | SLR0 % | SLR1 % | SLR2 % |
|----------------------------|--------|--------|--------|--------|--------|--------|
| CLB                        |  24490 |  36166 |  37216 |  49.72 |  73.42 |  75.55 |
|   CLBL                     |  12267 |  17902 |  18075 |  49.87 |  72.77 |  73.48 |
|   CLBM                     |  12223 |  18264 |  19141 |  49.57 |  74.06 |  77.62 |
| CLB LUTs                   | 109381 | 131667 | 146118 |  27.76 |  33.41 |  37.08 |
|   LUT as Logic             | 102111 | 116533 | 125870 |  25.91 |  29.57 |  31.94 |
|     using O5 output only   |    953 |   1360 |     12 |   0.24 |   0.35 |  <0.01 |
|     using O6 output only   |  79727 |  74527 |  79763 |  20.23 |  18.91 |  20.24 |
|     using O5 and O6        |  21431 |  40646 |  46095 |   5.44 |  10.31 |  11.70 |
|   LUT as Memory            |   7270 |  15134 |  20248 |   3.69 |   7.67 |  10.26 |
|     LUT as Distributed RAM |   7002 |   4268 |      0 |   3.55 |   2.16 |   0.00 |
|     LUT as Shift Register  |    268 |  10866 |  20248 |   0.14 |   5.51 |  10.26 |
|       using O5 output only |      0 |      0 |      1 |   0.00 |   0.00 |  <0.01 |
|       using O6 output only |     96 |   4782 |   8247 |   0.05 |   2.42 |   4.18 |
|       using O5 and O6      |    172 |   6084 |  12000 |   0.09 |   3.08 |   6.08 |
| CLB Registers              | 159680 | 278450 | 294595 |  20.26 |  35.33 |  37.38 |
| CARRY8                     |   1518 |   7595 |  18131 |   3.08 |  15.42 |  36.81 |
| F7 Muxes                   |   4818 |   1265 |      0 |   2.45 |   0.64 |   0.00 |
| F8 Muxes                   |    279 |    226 |      0 |   0.28 |   0.23 |   0.00 |
| F9 Muxes                   |      0 |      0 |      0 |   0.00 |   0.00 |   0.00 |
| Block RAM Tile             |  153.5 |    239 |     28 |  21.32 |  33.19 |   3.89 |
|   RAMB36/FIFO              |    152 |    235 |     24 |  21.11 |  32.64 |   3.33 |
|     RAMB36E2 only          |    128 |    235 |     24 |  17.78 |  32.64 |   3.33 |
|   RAMB18                   |      3 |      8 |      8 |   0.21 |   0.56 |   0.56 |
|     RAMB18E2 only          |      3 |      8 |      8 |   0.21 |   0.56 |   0.56 |
| URAM                       |    210 |    127 |    126 |  65.63 |  39.69 |  39.38 |
| DSPs                       |      0 |    859 |   2140 |   0.00 |  37.68 |  93.86 |
| PLL                        |      0 |      0 |      0 |   0.00 |   0.00 |   0.00 |
| MMCM                       |      0 |      0 |      0 |   0.00 |   0.00 |   0.00 |
| Unique Control Sets        |   4081 |   4585 |    127 |   4.14 |   4.65 |   0.13 |
|----------------------------|--------|--------|--------|--------|--------|--------|
