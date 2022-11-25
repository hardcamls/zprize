---
layout: default
title: hardcaml_zprize
---

# Hardcaml Zprize

This documentation describes two projects undertaken as part of the Zprize competition in 2022.

Our submitted code is available on [github here](https://github.com/fyquah/hardcaml_zprize)
(It will be made public after all competitions' deadline).

# Multi-scalar multiplication

* [Field Multiplication](msm_field_multiplication.html)
* [Point Representation](msm_point_representation.html)
* [Mixed Point Addition with Precomputation](msm_mixed_point_addition_with_precomputation.html)
* [Pippenger](pippenger.html)
* [Implementation Details](msm_implementation_details.html)
* [Results]()
* [msm\_host](msm_host.html)
* [msm\_test](msm_test.html)

The main submission document for msm is available with various design decisions
[on github as a README](https://github.com/fyquah/hardcaml_zprize/blob/master/zprize/msm_pippenger/README.md).

This is a competition to implement a multi-scalar multiplication. In particular, the goal is to
multiply 2{^26} BLS12-377 G1 affine points by 253 bit scalars from the associated scalar field and
add the result as fast as possible.

This is the submission for the FPGA track.

The main libraries that implements this include

- `Msm_pippenger` implements the complete MSM computation using the Pippenger
  bucket method.
- `Pippenger` implements the controller logic to sequence the MSM computation.
- `Field_ops_lib` implements the core field arithmetic operations (modulo
  multiplications etc.)
- `Twisted_edwards_lib` implements the mixed addition in the twisted edwards
  curve.

Some modules with interesting implementation are (but not limited to):

- `Twisted_edwards_lib.Mixed_add_precompute` - A fully pipelined mixed adder
  for points in the scaled twisted edwards curve with heavy precomputation.
- `Field_ops_lib.Bram_reduce` - Perform the fine reduction stage of barrett
  reduction using BRAMs.
- `Msm_pippenger.Scalar_transformation` - Transforms scalars into a signed
  digit representation.

# Inverse NTT

This competition track required us to build an Inverse Number
Theoretic Transform (INTT) accelerator capable of performing
transforms of size $2^24$.

NTT's are conceptually very similar to the well know Fast Fourier
Transform. The only difference is instead of working over complex
numbers, the transform works over a finite field. For this project the
finite field contains values of size 64 bits modulo a so called
[Solinas](https://en.wikipedia.org/wiki/Solinas_prime) prime equal to
$2^64 - 2^32 + 1$.

The platform tergetted was the Xilinx [Varium
C1100](https://www.xilinx.com/products/accelerators/varium/c1100.html)
accelerator card. The card contains fairly large Virtex UltrasScale+
FPGA with HBM2.

* [ntt](ntt.html)
* [ntt\_top](ntt_top.html)
* [ntt\_build\_instructions](ntt_build_instructions.html)

The main submission document for the NTT Acceleration contest is available [here](hardcaml_ntt).

In this competition, we create a FPGA design that performs a 2{^24} inverse
number theoretic transform over a 64 bit finite field.

The other documentation pages for this competition include:

- `Hardcaml_ntt` - documentation about the design of the main NTT core
- `zprize_ntt_build_instructions` - Building and testing instructions
