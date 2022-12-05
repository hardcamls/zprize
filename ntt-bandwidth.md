---
layout: default
title: Memory Bandwidth
category: ntt
subcategory: design
---

# Memory Bandwidth

THe 4 step algorithm requires both a column and row transform, with transposes between phases.
This is performed both by controlling the memory access pattern and by internally transposing
small blocks of data so they can be loaded in parallel into the individual INTT cores.

One significant issue we have faced with this project is the bandwidth performance of HBM. When
the input data is organised into a simple row major order we tend to burst 64 to 512 bytes before
opening a new row in HBM. The row open operation appears to be taking up to 200-250 HBM
clock cycles (about 100 cycles at our internal 200 Mhz clock).  This proves to be a significant
performance bottleneck for our design.

We are pretty sure that the UltraScale+ HBM controller can provide much better bandwidth than this,
but lacked time to see if we could get better results.

The total burst size is dependant on the number of parallel INTT cores and gets better the more
we have.  With our current maximum of 64 cores we burst $64*8=512$ bytes.

# Optimised layout

In order to show the actual performance of the design we needed a way to overcome the memory
bandwidth bottleneck that providing the input matrix in `normal layout` (ie row major order) suffers from.
This led us to experiment with an
[`optimised layout`](https://github.com/fyquah/hardcaml_zprize/blob/master/zprize/ntt/host/ntt_preprocessing.cpp)
design.

The optimised layouts uses the host for pre/post processing and dramatically improve bandwidth
efficiency.  Of the 4 memory transfers over 2 passes of the 4-step algorithm, 3 are totally linear,
and 1 has a burst size of 4096 with 64 cores (2048 with 32).  The host is required to transpose blocks of
data accessed 64 bytes at a time.

We see tremendously improved throughput of the core with this scheme, though the host processing
was relatively heavy (though still faster than the actual INTT computation, so could be hidden).

Due to the Zprize judging criteria, we don't expect this optimisation to be useful due to the
extra pre/post processing.  We include it none-the-less as it shows the potential performance
we can get to with either a more optimised HBM structure, or different memory architecture
(like DDR4).

# PCIe

The Varium C1100 cards are provided with a Vitis design infrastructure that supports a x4 Gen3 PCIe link.
Our INTT design can saturate that link, even with the HBM bandwidth limitations noted above.

We really need a full 16x PCIe link to push this design further.
