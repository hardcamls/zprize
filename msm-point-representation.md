---
layout: default
title: Twisted Edwards Point Representation
category: msm
subcategory: design
---

# Twisted Edwards Point Representation

We choose to convert points to the Twisted Edwards curve, rather than working in
the Weierstrass form. Point Addition in Twisted edwards curve is significantly
cheaper than in the vanilla weierstrass form.

This page details the algorithms to convert points in the original weistrass
form into scaled Twisted edwards form. We go into greater detail about [our
pipelined point adder in a different
page](msm-mixed-point-addition-with-precomputation.html).


## Converting Curve Parameters to Twisted Edwards

The transformation from the curve in Weierstrass form to Twisted Edwards form is a
2-step process. First it needs to be transformed to the Montgomery form, only
then it can be transformed to Twisted Edwards form. The [Wikipedia article on
Montgomery Curve](https://en.wikipedia.org/wiki/Montgomery_curve) has a good
explanation on this. Here is a summary of the algorithm.

An elliptic curve in Weierstrass form has the following formula:

$$ y^2 = x^3 + ax + b$$

where a and b are the parameters of the curve. (In BLS12-377 G1, $a = 0, b = 1$)

The Montgomery curve has the following formula:

$$By^2 = x^3 + Ax^2 + x$$

where A and B are the parameters of the curve

An elliptic curve in Weierstrass form is equivalent to a Montgomery
curve with the following parameter transformations:

$$A = 4αs$$

$$B = s$$

where $α$ is the root of the equation $x^3 + ax + b = 0$ and
$s = 1/√{3α^2 + a}$

Twisted Edwards curves have the following form:

$$ax^2 + y^2 = 1 + dx^2y^2$$

where $a$ and $d$ are parameters of the curve

A Montgomery curve is equivalent to a Twisted Edwards curve with the following
parameter transformation:

$$a = {A+2}/{B}$$

$$d = {A-2}/{B}$$

The linked Wikipedia article above goes into detail on the conditions when
these parameter transformations are valid. We validated that the required
assumptions do hold in BLS12-377 G1.

## Converting Points from Weierstrass to Twisted Edwards

Having converted the curve parameters, the point transformations are
straightforward:

Given $(x, y)$ on a curve in Weierstrass form:

$$x_{montgomery} = s(x - α)$$

$$y_{montgomery} = sy$$

Given $(x, y)$ on a Montgomery curve:

$$x_{twisted\_edwards} = x / y$$

$$y_{twisted\_edwards} = {x - 1} / {x + 1}$$

The main catch here is the mapping for points from Weierstrass to Twisted Edwards
is not defined when $y_{montgomery} = 0$ or $x_{montgomery} = -1$. This implies
there is no Twisted Edwards curve representation for points where $y = 0$ or $x
= α - 1/s$. There are exactly 5 such points on the BLS12-377 curve.

In practice, this is not a problem, as the probability of these points randomly
occurring is miniscule, so we can fallback to a slow code path when handling
these points. In our implementation, we offload these points to the host.

## Converting Points from Twisted Edwards into Scaled Twisted Edwards

A mixed addition on a Twisted Edwards curve [costs `8M + 1*a +
7A`](https://hyperelliptic.org/EFD/g1p/auto-twisted-extended.html#addition-madd-2008-hwcd-2)
(this notation means 8 field multiplication, 1 multiplication by a known
constant `a` and 7 field additions). But with a simple scaling transformation,
we can [reduce this further to `7M + 1*k + 8A +
1*2`](https://hyperelliptic.org/EFD/g1p/auto-twisted-extended-1.html#addition-madd-2008-hwcd-3).
The reduced operation count applies to Twisted Edwards curve with `a = -1`.

The coordinates can be transformed as follows:

$$x_{scaled} = (√{(-3αs - 2) / s}) x_{twisted\_edwards}$$

$$y_{scaled} = y_{twisted\_edwards}$$

where $α$ and $s$ are defined in the transformations above

The parameters of the scaled Twisted Edwards curve are:

$$a_{scaled} = -1$$

$$d_{scaled} = d_{twisted\_edwards} / a_{twisted\_edwards}$$
