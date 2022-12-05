---
layout: app
title: NTT Vitis Top Level
hardcaml_app: ntt_vitis_top.bc.js
---

Our top level Vitis kernel design, with multiple parallel NTT cores.

<br/>

Configure the size of the overall transform and number of parallel cores.

<br/>

Note that the parallelism is limited depending on the transform size and a suitable
maximum will be automatically applied when the design is generated.

<br/>

Running simulations for large transform sizes _will_ take a long time...
