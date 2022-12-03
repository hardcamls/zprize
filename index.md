---
layout: default
title: hardcaml_zprize
cname: landing
splash-header: true
---

<div class="heading-ribbon-container">

	<div class="heading-ribbon">

		<img class="zprize-heading" src="/assets/images/zprize-heading.png">

	</div>

</div>


# HARDCAML ZPRIZE


<div class="columns-container">

	<div class="column left">

		<h2>Multi-scalar multiplication</h2>

		<p>The Multi-scalar multiplication (MSM) competition tasked us with building an FPGA design to multiply $2^26$ points on the BLS12-377 elliptic curve (with the G1 subgroup generator) by scalars from the associated 253 bit scalar field and add them all as fast as possible.</p>

		<p>The platform targeted was Amazon F1, which uses a Xilinx UltraScale+ V9P FPGA with DDR memory banks.</p>

		<p>Read more about the <a href="msm_overview.html">implementation</a></p>

	</div>


	<div class="column right">

		<h2>Inverse NTT</h2>

		<p>This competition track required us to build an Inverse Number Theoretic Transform (INTT) accelerator capable of performing transforms of size $2^24$. INTTs are conceptually similar to the Fourier Transforms - working over a finite field instead of complex numbers.</p>

		<p>The platform tergetted was the Xilinx Varium C1100 accelerator card. The card contains Virtex UltrasScale+ FPGA with HBM2.</p>

		<p>Read more about the <a href="ntt-overview.html">implementation</a></p>

	</div>

</div>

