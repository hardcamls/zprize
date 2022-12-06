---
layout: default
title: Mixed Point Addition with Precomputation
category: msm
subcategory: design
---

# Mixed Point Addition with Precomputation

The main computation of the MSM design is performed by a fully pipelined point
adder. A mixed Twisted Edwards point adder computes the addition between a
running sum in [extended coordinate system](https://hyperelliptic.org/EFD/g1p/auto-twisted-extended-1.html)
and a point in affine coordinate system.

In our work, we implement a _strongly unified mixed adder_ with `7M + 6A`,
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
that formula is not strongly unified. Using this implementation would have
required us to carefully identify edge cases such as infinities and when the
two points are identical (despite being numerically unequal). Using a strongly
unified adder side-steps all of this entirely, which makes the MSM core a lot
easier to reason about.

## Note about Notation

In the text that follows, points in the affine coordinate system consist of 3
elements $(x,y,t)$, where $x * y = t$. Points in the extended coordinate
systems consist of 4 elements $(x,y,z,t)$, where $x/z × y/z = t/z$.

In both cases, $t$ is a redundant term meant make evaluation faster.

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

The key idea in our precomputation optimization is to do some preprocessing
in the affine points ahead of any evaluation and a single postprocessing on
the accumulation result per MSM. The preprocessing is non-trivial, but can be
computed ahead of time. The postprocessing is only executed once per
bucket, which is negligible.

## The Precomputation Optimization

The exact proof that these formulae are equivalent to the [vanilla mixed addition
formulae](https://hyperelliptic.org/EFD/g1p/auto-twisted-extended-1.html#addition-madd-2008-hwcd-3)
after the transformations is beyond the scope of this document, but it should
be a straightforward algebra exercise.


### Preprocessing on Affine Points

Ahead of any MSM evaluations, all affine points are transformed as follows:

$$
(x_{new},y_{new},t_{new}) → ( (y-x)/2, (y+x)/2, 4dt )
$$

### Formulae for Addition

Ahead of any MSM evaluations, all points are initialized to $(2, 2, 4, 0)$ (the
rationale of this number will be elaborated below). Addition between a
preprocessed affine point $(x_{affine}, y_{affine}, t_{affine})$ and the running
sum $(x_{running}, y_{running}, z_{running}, t_{running})$ is defined as follows:

$A = x_{running} × x_{affine}$

$B = y_{running} × y_{affine}$

$C = t_{running} × t_{affine}$

$D = z_{running}$

$E = B - A$

$F = D - C$

$G = D + C$

$H = B + A$

$I = E × F$

$J = G × H$

$t_{out} = E × H$

$z_{out} = F × G$

$x_{out} = J - I$

$y_{out} = J + I$

### Post-Processing

Upon completion of bucket aggregation, the bucket sum results are
post-processed using the following transformation:

$$
(p, q, r, s) → ( (p-q)/4, (p+q)/4, r/4, s )
$$

## Implementation Details

Our implementation supports a fully-pipelined mixed precompute adder (one that
can accept input every cycle). Our codebase also supports a half-pipelined adder
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
SLR. These registers are hierarchically created with SLR\{0,1,2\} suffix in
their instantiation name so they can be pblocked.

In our implementation, 2 field multiplications in our adder are in SLR1, and 5
of them are in SLR2.

Some big benefits of using Hardcaml is that we can parameterize our
design over these expressive configurations, and have them go through our
regular tests on our own machines and Github actions. This gives us confidence
that the design does not regress as we make config changes while conducting
experiments for SLR assignments, which very rapidly increases productivity.

Relevant code:

- [Modelling Code](https://github.com/fyquah/hardcaml_zprize/tree/master/libs/twisted_edwards/model)
- [Hardcaml Code for Adder](https://github.com/fyquah/hardcaml_zprize/blob/master/libs/twisted_edwards/src/mixed_add_precompute.ml)
