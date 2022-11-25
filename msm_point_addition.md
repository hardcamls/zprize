---
layout: default
title: Twisted Edwards Point Addition
---

# Twisted Edwards Point Addition

The main computation of the MSM design is performed by a fully pipelined point
addition core.

With the tricks documented here, we managed to get down to `7M + 6A`, a very
big improvement over [`7M + 4S + 9A` required for Jacobian
coordinates](https://hyperelliptic.org/EFD/g1p/auto-shortw-jacobian-0.html#addition-madd-2007-bl)

We did some modelling of all this in OCaml to validate all the requirements
for the transformations are met, and a point addition in twisted Edwards form do
indeed map to an addition in Weierstrass form (by using arkworks as a reference).
See [here](../../../libs/twisted_edwards/model) for our modelling tests.

## Converting to Scaled Twisted Edwards Curve

A mixed addition on the scaled twisted Edwards curve [costs `8M + 1*a + 7A`](https://hyperelliptic.org/EFD/g1p/auto-twisted-extended.html#addition-madd-2008-hwcd-2). But with a simple scaling transformation, we can [reduce
this further to `7M + 1*k + 8A + 1*2`](https://hyperelliptic.org/EFD/g1p/auto-twisted-extended-1.html#addition-madd-2008-hwcd-3).
The reduced operation count applies to twisted Edwards curve with `a = -1`. We
can achieve that by transforming our coordinate system once more:

$(u, v) → (ku, v)$

where $k = √{((-3αs) - 2) / s}$

In our actual implementation, we go one step further, reducing the amount of work to `7M + 6A`
by exploiting very heavy precomputation. The key idea is that the two summands do not
need to be in the same coordinate space. The exact algorithm used for precomputation is
[described here in the documentation of the precompute mixed adder component](https://fyquah.github.io/hardcaml_zprize/zprize/Twisted_edwards_lib/Mixed_add_precompute/index.html)

While there is a [mixed addition formula for addition in scaled twisted Edwards form with `7M + 8A`](https://hyperelliptic.org/EFD/g1p/auto-twisted-extended-1.html#addition-madd-2008-hwcd-4), that formulae is not strongly unified. This means we need to specially handle identities and
cases where both points are equivalent (in affine coordinates). Although we are guaranteed
that the input points do not contain infinites (also known as identity points), our intermediate result
and initial state can still contain infinities. Having a strongly unified adder makes dealing with
this a lot of this easier to reason about.

## Precomputation Optimization

<!-- CR fquah: Fill this in -->
