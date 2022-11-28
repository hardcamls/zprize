---
layout: default
title: MSM overview
---

# Code structure

The code is built from various libraries within our [submission repository](https://github.com/fyquah/hardcaml_zprize).

- [`Msm_pippenger`](https://github.com/fyquah/hardcaml_zprize/tree/master/zprize/msm_pippenger) ([source code docs](odoc/zprize/Msm_pippenger/index.html)) implements the complete MSM computation using the Pippenger bucket method.
- [`Pippenger`](https://github.com/fyquah/hardcaml_zprize/tree/master/libs/pippenger) ([source code docs](odoc/zprize/Pippenger/index.html)) implements the controller logic to sequence the MSM computation
- [`Field_ops_lib`](https://github.com/fyquah/hardcaml_zprize/tree/master/libs/field_ops) ([source code docs](odoc/zprize/Field_ops_lib/index.html)) implements the core field arithmetic operations (modulo multiplications etc.)
- [`Twisted_edwards_lib`](https://github.com/fyquah/hardcaml_zprize/tree/master/libs/twisted_edwards) ([source code docs](odoc/zprize/Twisted_edwards_lib/index.html)) implements the mixed addition in the twisted edwards curve.

# Design overview

Learn more about our design.

* [Field Multiplication](msm_field_multiplication.html)
* [Point Representation](msm_point_representation.html)
* [Mixed Point Addition with Precomputation](msm_mixed_point_addition_with_precomputation.html)
* [Top level Pippenger design](pippenger.html) and it's [controller](msm-pippenger-controller.html)
* [Implementation Details](msm_implementation_details.html)
* [Results](msm_results.html)
* [Future Work](msm_future_work.html)
* [Host driver software](msm_host.html)
* [Benchmarking and test harness](msm_test.html)
