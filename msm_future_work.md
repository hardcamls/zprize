---
layout: default
title: Future Work
---

# Future Work

## Improving the Field Multiplication

**Exploiting Signed Multipliers** The DSP slices are capable of performing
$28 × 18$ _signed_ multiplication, which we currently just set the sign bit to 0.
The karatsuba ofman algorithm contains a subtraction in its intermediate
computation, which should be able to make use of the sign bit.

**Rectangular Karatsuba-Ofman** [These slides](http://www.bogdan-pasca.org/resources/talks/Karatsuba.pdf)
from Pasca et. al. describes performing the karatsuba-ofman multiplication
which fully utilizes non uniform input widths of the multipliers in the DSP
slice. The slides describes results for $55 × 55$ multipliers, which we believe
should be able to be extended to much larger multipliers.

## Host Driver
