---
layout: default
title: Top-Level Pippenger Design
category: msm
subcategory: design
---

# Top-Level Pippenger Design

## Pippenger's Algorithm

The main idea of [Pippenger's algorithm](https://dl.acm.org/doi/abs/10.1137/0209022)
reformulate the dot product $∑↙{i=0}↖{N-1} p_{i} s_{i}$ into smaller dot
product over windows, where every window represents a view over bits of the scalar.

$$∑↙{w=0}↖{W-1} 2^{wB} (∑↙{b=0}↖{2^{B}-1} b ∑↙{i=0}↖{N-1} p_{i} select\_bits(s_{i}, (w + 1)B - 1, wB)) $$

where $p_{i}$ and $s_{i}$ are elements of the prime field and scalar fields
respectively, and $BW$ must be greater or equal to the number of bits of the
scalar fields.

The inner sum parantheses is computed using the bucket method depicted by
the following python pseudocode.

```python
B : int = .. # log size of buckets, This is a tunable parameter.
identity = ...  # A special point such that P + identity = identity + P = P

def bucket_sum(scalars, points):
  buckets = [ identity for p in range(2**B) ]
  for scalar, point in zip(scalars, points):
    buckets[scalar] += point
  return buckets

def bucket_aggergation(bucket):
  acc = identity
  running = identity
  for point in reversed(points):
    running += point
    acc += running
  return acc

def bucket_method(scalars, points):
  return bucket_aggregation(bucket_sum(scalars, points))
```

## Overview of the Architecture

In the specific case of BLS12-377, the prime field and scalar field are 377
bits and 253 bits respectively. In our implementation, we have partitioned the
work such that the FPGA performs the `bucket_aggergation` and the host performs
the `bucket_sum`. When processing multiple MSMs, this allow us to mask out
some of the latency of bucket aggregation by starting the bucket sum of the next
MSM while computing bucket aggregation for the current MSM.

The consideration for the choice of parameters $B$ and $W$ are for this choices
are:

- The amount of on-chip memory resources available in the FPGA
- The amount of time taken to perform the bucket aggregation on the host

We have chosen $B=13$ and $W=20$ in our implementation, as this uses up ~60% of
the memory resources available and the time taken for bucket aggregation is
around 1/10th the time taken for bucket sum. This allows our implementation to
have a comfortable margin for routing in the FPGA and for the bucket
accumulation to be fast enough relative to bucket sum. We discuss some ideas on
improving the performance further in the [future work
section](msm-future-work).

## FPGA Dataflow

Here's a high level block diagram showing the different data flows and modules
used in our MSM implementation.

![Block diagram](images/msm-block-diagram.png)

Points are transformed into a custom representation and pre-loaded into DDR-4,
so that at run time only scalars are sent from the host to the FPGA via PCIe.

A single fully-pipelined point adder on the FPGA which adds points to buckets
as directed by a pippenger controller until there are no more points left. Once
all points have been added into buckets, the FPGA streams back the result for
the host to do the final bucket aggregatioin.

This approach allows us to focus on implementing a very high performance adder
on the FPGA (as these additions dominate Pippenger's algorithm), and then
leaving smaller tasks for the host to perform.

## FPGA Bucket Sum

In our implementation, the meat of the computation is performned by a fully
pipelined point adder with a high but static latency (>200 cycles). Naively, if
a coefficient needs to be added to a bucket that is currently in use by the
point adder we need to wait until the addition is complete before trying again.
Waiting 200 clock cycles will severely affect performance. The page about the
[pippenger controller](msm-pippenger-controller) discusses some tricks to
minimize the impact of this.

We utilize a well-known trick to reduce the memory usage by [transforming the
scalar](msm-scalar-transformation) into signed digit representation for scalars
for every bucket.

## FPGA Point Adder

The most expensive parts of of the pipelined point adder computation is
[field multiplications](msm-field-multiplication). Our implementation is
based around well-known tricks in barrett reduction.

To reduce the numberf of field multiplications, we [convert the points
representation](msm-point-representation) from it's original weistrass-curve
form into twisted edwards curve representation. This reduces the amount of
field multiplication substantially. We go one step further to reduce the field
multiplication operations with [some precomputation tricks in the adder
implementation](msm-mixed-point-addition-with-precomputation).
