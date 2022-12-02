---
layout: default
title: hardcaml_zprize
---

# Hardcaml Zprize

In 2022, we, the hardcamls team (Andy Ray, Ben Devlin, Fu Yong Quah, Rahul
Yesantharao) participated in the Zprize competition. We competed in the
Multi-Scalar Multiplication (MSM) and Inverse Number Theoretic Transform
(INTT).

Read on to find out more about our submissions and view the code on
[github](https://github.com/fyquah/hardcaml_zprize).

## Multi-scalar multiplication

The Multi-scalar multiplication (MSM) competition tasked us with building an FPGA design
to multiply $2^26$ BLS12-377 G1 affine points by 253 bit scalars from the associated
scalar field and add them all as fast as possible.

The platform targeted was
[Amazon F1](https://aws.amazon.com/ec2/instance-types/f1/)
which uses Xilinx UltraScale+ V9P FPGAs.

Read more about the [implementation](msm_overview.html)

## Inverse NTT

This competition track required us to build an Inverse Number
Theoretic Transform (INTT) accelerator capable of performing
transforms of size $2^24$.

NTT's are conceptually very similar to the well known Fast Fourier
Transform. The only difference is instead of working over complex
numbers, the transform works over a finite field. For this project the
finite field contains values of size 64 bits modulo a so called
[Solinas](https://en.wikipedia.org/wiki/Solinas_prime) prime equal to
$2^64 - 2^32 + 1$.

The platform tergetted is the Xilinx [Varium
C1100](https://www.xilinx.com/products/accelerators/varium/c1100.html)
accelerator card. The card contains Virtex UltrasScale+ FPGA with HBM2.

Read more about the [implementation](ntt-overview.html).

