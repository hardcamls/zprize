---
layout: default
title: Twisted Edwards Point Representation
---

# Twisted Edwards Point Representation

We chose to convert to the twisted Edwards curve, rather than working in the
Weierstrass form, to reduce resource usage of the pipelined mixed adder. This
page describes how to convert the given points (which are in Weistrass form)
to twisted edwards form.

## Converting Curve Parameters to Twisted Edwards

The transformation from the curve in Weierstrass form to twisted Edwards form is a
2-step process - First it needs to be transformed to the Montgomery form, only
then it can be transformed to the elliptic curve form. The [Wikipedia article on
Montgomery Curve](https://en.wikipedia.org/wiki/Montgomery_curve) has a good
explanation on this.

Here is a summary of the method.

An elliptic curve in Weierstrass form has the following formula:

$y^2 = x^3 + ax + b$

where a and b are the parameters of the curve. (In BLS12-377 G1, $a = 0, b = 1$)

The Montgomery curve has the following formula:

$y^2 = x^3 + (A * x^2) + x$

where A and B are the parameters of the curve

An elliptic curve in Weierstrass form can be rewritten as a Montgomery
curve by transforming the parameters as follows (whenever the parameter α
as defined below exists - it does exist for BLS12-377 G1).

$A = 3αs$

$B = s$

where $α$ is the root of the equation $x^3 + ax + b = 0$ and 
alpha is a root of the equation 
$s = 1/√{(3α^2) + a)}$

Twisted Edwards curves have the following form:

$ax^2 + y^2 = 1 + dx^2y^2$

where $a$ and $d$ are parameters of the curve

A Montgomery curve can be rewritten as a twisted Edwards curve with the following
formulae when $a ≠ d$:

$A = {2(a + d)}/{a - d}$

$B = 4 / (a - d)$

The linked Wikipedia article above goes into detail on when these parameter
transformations are valid. We validated that the required assumptions
do hold in BLS12-377, and hence can be represented as a twisted Edwards curve.

## Converting Points from Weierstrass to Twisted Edwards

The formulae for points conversion is detailed in the Wikipedia article
linked above. Here's a summary:

Given $(x, y)$ on a curve in Weierstrass form:

$x_{montgomery} = s * (x - α)$

$y_{montgomery} = s * y$

Given (x, y) on a Montgomery curve:

$x_{twisted\\_edwards} = x / y$

$y_{twisted\\_edwards} = {x - 1} / {x + 1}$

The main catch here is the mapping for points from Weierstrass to twisted Edwards
is not always defined. The transformation for points from Montgomery curve
-> twisted Edwards is undefined when $y = 0$ or $x = -$` on the Montgomery curve
representation. This implies there is no twisted Edwards curve representation
for points where $y = 0$ or $x = alpha - s^{-1}$. There are exactly 5 such
points on the BLS12-377 curve.

In practice however, this is not a problem, as:

- The probability of these points occurring is miniscule, so we can fallback
to a slow code path when handling these points. In our implementation, we simply
offload these points to the CPU.
- It's unclear if these points lie in the G1 subgroup, so it's not clear if
  this case will ever occur at all!

## Converting Points from Twisted Edwards into Scaled Twisted Edwards

A mixed addition on a Twisted Edwards Curve [costs `8M + 1*a + 7A`](https://hyperelliptic.org/EFD/g1p/auto-twisted-extended.html#addition-madd-2008-hwcd-2). But with a simple scaling transformation, we can [reduce
this further to `7M + 1*k + 8A + 1*2`](https://hyperelliptic.org/EFD/g1p/auto-twisted-extended-1.html#addition-madd-2008-hwcd-3).
The reduced operation count applies to twisted Edwards curve with `a = -1`.

We can do this by transforming our coordinate system to:

$(u, v) → ((√{(-3αs - 2) / s}) u, v)$
