---
layout: default
title: MSM overview
category: msm
subcategory: overview
---

# Multi-Scalar Multiplication (MSM)

The Multi-Scalar multiplication (MSM) competition tasked us with building an
FPGA design to multiply $2^26$ points on the BLS12-377 elliptic curve (with the
G1 subgroup generator) by scalars from the associated 253 bit scalar field and
add them all as fast as possible.

The platform targeted was [Amazon
F1 f1.2xlarge](https://aws.amazon.com/ec2/instance-types/f1/), which uses a Xilinx
UltraScale+ VU9P FPGA with DDR memory banks. We have utilized the [aws-fpga
Vitis flow](https://github.com/aws/aws-fpga/blob/master/Vitis/README.md) in our
implementation.

# Design overview

Learn more about our design.

* [Field Multiplication](msm_field_multiplication.html)
* [Point Representation](msm_point_representation.html)
* [Scalar Transformation](scalar_transformation.html)
* [Mixed Point Addition with Precomputation](msm_mixed_point_addition_with_precomputation.html)
* [Top level Pippenger Algorithm Design](pippenger.html)
* [Pippenger controller](msm-pippenger-controller.html)
* [Implementation Details](msm_implementation_details.html)
* [Results](msm_results.html)
* [Future Work](msm_future_work.html)
* [Host driver software](msm_host.html)
* [Benchmarking and test harness](msm_test.html)

# Hardcaml on the Web

Configure our designs, download RTL and perform simulations all within the
comfort of your web browser!

- [Karatsuba ofman multiplier](apps/msm/msm-karatsuba-ofman-mult.html)
- [Barrett Reduction](apps/msm/msm-barrett-reduction.html)
- [Top level design as a Vitis kernel](apps/msm/msm-top-app.html)

# Code structure

The code is built from various libraries within our [submission repository](https://github.com/fyquah/hardcaml_zprize).
API Docs are available [here](/odoc/zprize/index.html#multi-scalar-multiplication).

- [`Msm_pippenger`](https://github.com/fyquah/hardcaml_zprize/tree/master/zprize/msm_pippenger) ([source code docs](odoc/zprize/Msm_pippenger/index.html)) implements the complete MSM computation using the Pippenger bucket method.
- [`Pippenger`](https://github.com/fyquah/hardcaml_zprize/tree/master/libs/pippenger) ([source code docs](odoc/zprize/Pippenger/index.html)) implements the controller logic to sequence the MSM computation
- [`Field_ops_lib`](https://github.com/fyquah/hardcaml_zprize/tree/master/libs/field_ops) ([source code docs](odoc/zprize/Field_ops_lib/index.html)) implements the core field arithmetic operations (modulo multiplications etc.)
- [`Twisted_edwards_lib`](https://github.com/fyquah/hardcaml_zprize/tree/master/libs/twisted_edwards) ([source code docs](odoc/zprize/Twisted_edwards_lib/index.html)) implements the mixed addition in the twisted edwards curve.

