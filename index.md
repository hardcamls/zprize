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


# Hardcaml Zprize


<div class="columns-container">

	<div class="column left">

		<h2>Multi-scalar multiplication</h2>

		<p>The Multi-scalar multiplication (MSM) competition tasked us with building an FPGA design to multiply $2^26$ BLS12-377 G1 affine points by 253 bit scalars from the associated scalar field and add them all as fast as possible.</p>

		<p>The platform targeted was <a href="https://aws.amazon.com/ec2/instance-types/f1/">Amazon F1</a> which uses Xilinx UltraScale+ V9P FPGAs.</p>

		<p>Read more about the <a href="msm_overview.html">implementation</a></p>

	</div>


	<div class="column right">

		<h2>Inverse NTT</h2>

		<p>This competition track required us to build an Inverse Number Theoretic Transform (INTT) accelerator capable of performing transforms of size $2^24$.</p>

		<p>NTT's are conceptually very similar to the well known Fast Fourier	Transform. The only difference is instead of working over complex numbers, the transform works over a finite field. For this project the finite field contains values of size 64 bits modulo a so called <a href="https://en.wikipedia.org/wiki/Solinas_prime">Solinas prime</a> equal to $2^64 - 2^32 + 1$.</p>

		<p>The platform tergetted is the Xilinx <a href="https://www.xilinx.com/products/accelerators/varium/c1100.html">Varium C1100</a> accelerator card. The card contains Virtex UltrasScale+ FPGA with HBM2.</p>

		<p>Read more about the [implementation](ntt-overview.html).</p>

	</div>

</div>

