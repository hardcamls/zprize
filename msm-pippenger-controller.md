---
layout: default
title: Pippenger Controller
---

# Pippenger controller

The key computation of the pippenger algorithm is adding each input coefficient to a value
stored in RAM (also called a bucket).  This would be trivial except for the latency of the 
elliptic curve (EC) adder.

In our design the latency is over 200 clock cycles.  If a coefficient needs to be added
to a bucket that is currently in use by the EC adder we need to wait until the addition
is complete before trying again.

The trivial solution of just waiting for the pipeline to flush would be extremely expensive.
With table sizes of around 4K, and a pipeline depth of 200 we would expect buckets to
be busy in the pipeline around 5% of the time.  Waiting on average 100 cycles per hazard
would unacceptably hurt our performance.

Instead our controller uses a couple of simple heuristics to try to keep the pipeline as
busy as possible, while avoiding data hazards.

## Scalar tracking

We need to store 200 RAM locations to track data through the pipelin and check if a new
coefficient would cause a hazard.  Naively done this would require 200 comparators in parallel
and then a wide OR reduction.

In our controller we actually process mutliple windows on successive clock cycles.  In
our current design we have 2 seperate controllers tracking about 10 windows
each.  Since there can be no hazard between windows, we only need to compare and OR reduce
$1/10$ of the scalars in the pipeline.

## Stalled point FIFO

When we detect a hazard the coefficient and related scalar are placed in a stalled point
FIFO and we insert a bubble into the pipeline for that cycle.

There are seperate FIFOs for each window being processed.

The FIFOs are only a few elements in size and are actually all combined into a single 
(wide) set of RAMs.

## Heuristics

We initially did some 
[Modelling](https://github.com/fyquah/hardcaml_zprize/blob/master/libs/pippenger/bin/model.ml)
to try to find an efficient algorithm.

Here's what we came up with.

1. If all the stalled point FIFOs have a least one element, attempt to process them
2. If any of the stalled point FIFOs are full, process them.
3. Otherwise process incoming data.

## Improvements

When initially designed, we thought we could only fit an EC adder than accepted a new
input every 2 clock cycles.  As such the controller was also designed to output a new value
every two cycles.  For the final design we had a single cycle adder, and just instantiated
2 seperate controllers working on half the windows each to get full throughput.  This is not
terribly inefficient, but does require 2 copyes of the scalar tracking pipeline which is
unneccesary.

We also think we could get rid of nearly all bubbles in the pipeline if we presented the
controller twp new points per cycle.  The chances of both being a hazard are greatly 
reduced.  We would expect to gain an extra 4-5% performance with this change.
