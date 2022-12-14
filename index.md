---
layout: default
title: Hardcaml ZPrize
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

		<div class="upper">

			<div class="heading"><h2>Multi-Scalar multiplication</h2></div>

			<div class="content">

				<p>The Multi-Scalar multiplication (MSM) competition tasked us with building an FPGA design that multiplies $2^26$ points on the BLS12-377 elliptic curve (with the G1 subgroup generator) by scalars from the associated 253-bit scalar field and add them all as fast as possible.</p>

				<p>The platform targeted was Amazon F1 which uses a Xilinx UltraScale+ V9P FPGA with DDR memory banks.</p>

			</div>

		</div>

		<a href="msm-overview.html">
			<div class="cta-button">
				<p>Read more about the implementation</p>
			</div>
		</a>

	</div>


	<div class="column right">

		<div class="upper">

			<div class="heading"><h2>Number Theoretic Transform</h2></div>

			<div class="content">

				<p>This competition track required us to build a Number Theoretic Transform (NTT) accelerator capable of performing transforms of size $2^24$. NTTs are conceptually similar to the Fourier Transforms - working over a finite field instead of complex numbers.</p>

				<p>The platform targeted was the Xilinx Varium C1100 accelerator card. The card contains a Virtex UltrasScale+ FPGA with HBM2.</p>

			</div>

		</div>

		<a href="ntt-overview.html">
			<div class="cta-button">
				<p>Read more about the implementation</p>
			</div>
		</a>

	</div>

</div>

