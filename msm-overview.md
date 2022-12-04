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

The mathematical formulation of the MSM problem is as follows:

$$MSM(p, s) = ∑↙{i=0}↖{N-1} p_{i} s_{i}$$

where $p_{i}$ are points on the BLS12-377 elliptic curve, $s_{i}$ are
scalars from a corresponding 253-bit scalar field and $N$ is the number of
points. The points $p_{i}$ are known at initialization, but the scalars $s_{i}$
are only known during evaluation.

The challenge here is that [point
addition](https://en.wikipedia.org/wiki/Elliptic_curve_point_multiplication#Point_addition)
(adding two elliptic curve points together) and [point
multiplication](https://en.wikipedia.org/wiki/Elliptic_curve_point_multiplication#Point_multiplication)
(multiplying a point on an elliptic curve by a scalar) are both very expensive
operations.

The platform targeted was [Amazon
f1.2xlarge](https://aws.amazon.com/ec2/instance-types/f1/), which uses a Xilinx
UltraScale+ VU9P FPGA with DDR memory banks. We have utilized the [aws-fpga
Vitis flow](https://github.com/aws/aws-fpga/blob/master/Vitis/README.md) in our
implementation.

# Design overview

Our implementation is built around pippenger's algorithm to compute
multi-scalar multiplication. Our implementation splits work between the
FPGA and the host device. The pages below describes the architecture of our
design and the main controller to compute pippenger's algorithm.

* [Top level Pippenger Design](pippenger.html)
* [Pippenger Controller](msm-pippenger-controller.html)

The heart of the computation is performed by a 1-per-cycle throughput mixed
adders. The pages below details the mathematics behind the implementation of
the adder.

* [Field Multiplication](msm-field-multiplication.html)
* [Point Representation](msm-point-representation.html)
* [Scalar Transformation](msm-scalar-transformation.html)
* [Mixed Point Addition with Precomputation](msm-mixed-point-addition-with-precomputation.html)

We discuss the low-level engineering implementation details, final results
and reproduction guides in the pages below.

* [Implementation Details](msm-implementation-details.html)
* [Host driver software](msm-host.html)
* [Results](msm-results.html)
* [Building, Testing and Benchmarking](msm-test.html)

We possible improvements on our work in the following page.

* [Future Work](msm-future-work.html)

# Hardcaml on the Web

Configure our designs, download RTL and perform simulations all within your browser!

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

