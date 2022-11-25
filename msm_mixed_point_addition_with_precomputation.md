---
layout: default
title: Mixed Point Addition with Precomputation
---

# Mixed Point Addition with Precomputation

The main computation of the MSM design is performed by a fully pipelined point
addition core. The addition cores computes the addition of a point in
[extended coordinate system](https://hyperelliptic.org/EFD/g1p/auto-twisted-extended-1.html) and an affine point in extended coordinate system but with $z = 1$.

In our work, we managed to get a _strongly unified mixed adder_ with `7M + 6A`,
by exploiting some precomputation. This is a very big improvement over [`7M +
4S + 9A` required for Jacobian coordinates](https://hyperelliptic.org/EFD/g1p/auto-shortw-jacobian-0.html#addition-madd-2007-bl), and
a small but meaningful improvement over [existing known methods for
twisted edwards curves (`8M + 1*a + 7A`)](https://hyperelliptic.org/EFD/g1p/auto-twisted-extended.html#addition-madd-2008-hwcd-2)
and  [scaled twisted edwards curves (`7M + 1*k + 8A + 1*2`)](https://hyperelliptic.org/EFD/g1p/auto-twisted-extended-1.html#addition-madd-2008-hwcd-3).
Decreasing a multiplication might not seem like a lot, but when making FPGA
designs operating at the edge at the device's capabilities, every little counts
in increasing performance!

While there is a [mixed addition formula for addition in scaled twisted Edwards
form with `7M + 8A`](https://hyperelliptic.org/EFD/g1p/auto-twisted-extended-1.html#addition-madd-2008-hwcd-4),
that formulae is not strongly unified. Using this implementation would have
required us to carefully identify edge cases such as infinities and when the
two points are identical (despite being numerically unequal). Using a strongly
unified adder side-steps all of this entirely, which makes the MSM core a lot
easier to reason about.

## Workload Nature

The nature of our adder's workload looks something like computing a running
sum, ie something like the following:

```python
# ps is loaded at startup, and doesn't change across every evaluation batch,
ps = load_affine_points()

# workload_for_adder_for_batch is called for every batch
def workload_for_adder_for_batch(indices):
  acc = identity_element
  for i in indices:
    acc = add(acc, ps[i])
  return acc
```

We can make some observations here:
- The intermediate value of `acc` is never accessed
- `ps` is known ahead of time

The key idea in our precomputation optimization is to express the running sum 
and affine points in a different coordinate system from the extended
coordinate system. In the end of the computation, the running sum is converted
back to the extended coordinate system.

## The Precomputation Optimization

### Coordinate System for Running Sum

The running sum in the FPGA is usually represented in
[extended coordinate system](https://hyperelliptic.org/EFD/g1p/auto-twisted-extended-1.html).

We can transform a point in the extended coordinate system to our running sum
coordinate system using the formulae below:

$ (x, y, z, t) → ( 2(y-x), 2(y+x), 4z, t ) $

Note that this means that the identity element in this coordinate system
is no longer just $(0, 1, 1, 0)$, but rather $(2, 2, 4, 0)$. Also note that
$x/z × y/z ≠ t/z$ in the new coordinate system.

This is transformed back to the standard extended twisted edwards coordinate
system at the end of a batch of workload using the following formulae:

$ (p, q, r, s) → ( (p-q)/4, (p+q)/4, r/4, s ) $

### Coordinate System for Affine Points

The affine points have a completely different transformation algorithm:

$ (x,y,t) → ( (y-x)/2, (y+x)/2, 4dt ) $

Simliar to the running sum's internal representation, $x × y ≠ t$ in the
new coordinate system. Unlike running sum, we will never convert this back
to the projective coordinates. It's main purpose to be converted into this
coordinate system is to be added into the running sum efficiently.

Addition between these two newly defined coordinate system is as follows:

```
let add_unified_with_precompute running_sum static_point =
  let { x; y; t; z } = running_sum in
  let { x_host; y_host; t_host } = static_point in
  let c_A    = x1 * x_host in
  let c_B    = y1 * y_host in
  let c_C    = t1 * t_host in
  let c_D    = z1 in
  let c_E    = c_B - c_A in
  let c_F    = c_D - c_C in
  let c_G    = c_D + c_C in
  let c_H    = c_B + c_A in
  let pre_x3 = c_E * c_F in
  let pre_y3 = c_G * c_H in
  let t3     = c_E * c_H in
  let z3     = c_F * c_G in
  let x3     = pre_y3 - pre_x3 in
  let y3     = pre_y3 + pre_x3 in
  { x = x3; y = y3; z = z3; t = t3 }
;;
```

The exact proof of that this is equivalent to the
[vanilla mixed addition formulae](https://hyperelliptic.org/EFD/g1p/auto-twisted-extended-1.html#addition-madd-2008-hwcd-3)
after the transformations is beyond the scope of this document, as it is too
large to fit in the margin of our screen. But it should be easy to convince
yourself that it's doing the same thing.

## Implementation Details

Our implementation supports a fully-pipelined mixed precompute adder (one that
can accept input every cycle). Our codebase does support a half-pipelined adder
(one that can accept input every two cycles), but we did not use it as part of
our final design.

The configuration of the adder can be specified via the a
[config type](https://github.com/fyquah/hardcaml_zprize/blob/master/libs/twisted_edwards/src/config.ml).
The `slr_assignments` field in the config allows the user to
specify which SLR every stage should be mapped to. Under the hood, this
does two things:

- inserts a SLR\{0,1,2\} suffix to the instantiation name, which the user
can use for pblocking in placement
- automatically insert registers between stages which are not in the same
SLR. These registers are hierachically created with SLR\{0,1,2\} suffix in
their instantiation name so they can be pblocked.

In our implementation, 2 multiplications in our adder is in SLR1, and 5 of them
are in SLR2.

Some big benefits of using Hardcaml is that we can parameterize our
design over these expressive configurations, and have them go through our
regular tests on our own machines and Github actions.  This gives us confidence
that the design does not regress as we make config changes while conducting
experiments for SLR assignments, which very rapidly increases productivity.

Relevant code:

- [Modelling Code](https://github.com/fyquah/hardcaml_zprize/tree/master/libs/twisted_edwards/model)
- [Hardcaml Code for Adder](https://github.com/fyquah/hardcaml_zprize/blob/master/libs/twisted_edwards/src/mixed_add_precompute.ml)
