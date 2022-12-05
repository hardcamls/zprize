---
layout: default
title: Building, Testing and Benchmarking
category: msm
subcategory: design
---

# Building, Testing and Benchmarking

Please clone our [submission github
repository](http://github.com/fyquah/hardcaml_zprize) before following any
instructions below.

## Building the design from source

Instructions are given below for building from source. A prerequisite is that
OCaml has been set up (outlined in the main [README.md](https://github.com/fyquah/hardcaml_zprize/blob/master/README.md)).

It is important you use the AMI version 1.10.5 and Vivado version 2020.2 to
achieve the same results. The `rtl_checksum` expected of the Verilog when
generated from the Hardcaml source is 1929f78e1e4bafd9cf88d507a3afa055.

### Compiling the BLS12-377 reference

Run `cargo build` in `libs/rust/ark_bls12_377_g1` to compile the dynamic library
exposing a reference implementation of the BLS12-377 g1 curve. This is
necessary for the unit tests and verilog generator to work correctly.

z3 should also be installed to run Hardcaml RTL simulations.

### Generating the Verilog from Hardcaml

The following instructions assume you are in the `zprize/msm_pippenger` folder.

The Hardcaml code can be built by calling `dune build`, which will also cause
the top level Verilog to be generated in
`fpga/krnl_msm_pippenger/krnl_msm_pippenger.v`. We also provide a dune target
for generating an md5sum `fpga/krnl_msm_pippenger/rtl_checksum.md5` of the
Verilog expected, so that if changes to the Hardcaml source are made that modify
the Verilog (which is not checked into the repo), the rtl-checksum will show a
difference.

#### Simulations in Hardcaml

We have various expect tests in the [test folders](https://github.com/fyquah/hardcaml_zprize/blob/master/zprize/msm_pippenger/hardcaml/test) which can be
run by calling `dune runtest`. To optionally run a longer simulation, we added
binaries that can be called and various arguments set. These run with the
[Verilator](https://www.veripool.org/verilator/) backend, which after a longer
compile time, will provide much faster simulation time than the built-in
Hardcaml simulator. Make sure you have Verilator installed when running this
binary. To simulate 128 random points, run the following command:

```
dune exec ./hardcaml/bin/simulate.exe -- kernel -num-points 128 -verilator -timeout 1000000
```

The `-waves` switch can be optionally provided to open the simulation in the
Hardcaml waveform viewer. A larger timeout should be provided when simulating
more points.

### Building an FPGA image for AWS

You should build the FPGA image on an AWS box with the [FPGA Developer
AMI](https://aws.amazon.com/marketplace/pp/prodview-gimv3gqbpe57k) installed.
Make sure to clone the [aws-fpga repo](https://github.com/aws/aws-fpga/) to
`~/aws-fpga`. We used the `2a36c4d76b68bb9c60bf2f7b0be0fd9ea134978e`
revision of the repository.

Run the following to set up the necessary environment for the build.

```
source ~/aws-fpga/vitis_setup.sh
```

Navigate into the `fpga` directory which contains the scripts to build an actual FPGA
design (takes 8-10 hours). The compile script below will also build the Hardcaml
to generate the required Verilog. As this takes awhile, it is recommended that
you run this from a tmux session in the build instance.

```
cd fpga
./compile_hw.sh
```

The image built from the source at the time of writing will produce an FPGA
AFI that runs at 278MHz, automatically clocked down from 280MHz by Vitis.

We have done repeated builds to make sure the image built from source is
identical to what we tested. As a checkpoint, here are a few checksums that will
be reported by Vivado:

```
Phase 1.1 Placer Initialization Netlist Sorting | Checksum: e1119738
Ending Placer Task | Checksum: 1625c9702
Phase 4.1 Global Iteration 0 | Checksum: 2d7b45461
Phase 4.5 Global Iteration 4 | Checksum: 231df891e
Phase 13 Route finalize | Checksum: 176e41d90
```

#### Creating the AWS AFI

Once you have successfully called `compile_hw.sh` in the `fpga` folder, you want
to pass the results to the AWS script responsible for generating the AFI an
end-user can run:

```
./compile_afi.sh
```

After running the `compile_afi.sh` script, there should be a folder 'afi/'. Get
the afi id from the file `afi/{date}_afi_id.txt` and run the following command
to track the progress of its creation:

```
aws ec2 describe-fpga-images --fpga-image-ids <afi-...>
```
Which will show up as "available" when the image is ready to use.

## Benchmarking and Testing

### AWS setup

You need to run these steps on an AWS F1 box with an FPGA. Make sure you have
cloned the aws-fpga repo and run:

```
source ~/aws-fpga/vitis_runtime_setup.sh
```

Optionally check the status of the FPGA:

```
systemctl status mpd
```

You need the .awsxclbin file from the build box - usually the easiest way is to
download this from the s3 bucket or scp it over.

### MSM FPGA Test Harness

We include a modified version of the [GPU MSM test harness](https://github.com/z-prize/test-msm-gpu)
for testing and benchmarking our FPGA design. A feature we added is the ability
to load test data from a file using an environment variable
`TEST_LOAD_DATA_FROM`.

As the original GPU test harness expected the points returned by the FPGA to
be in projective form. We modified our host driver code to convert our result
point to this form.

The input and output points Basefield values are all in (or expected to be in)
Montgomery form (Montgomery here refers to Montgomery multiplication). This
is also some extra work that we are required to do in precomputation and
during evaluation, as we don't represent our points internally in Montgomery
space.

### Generating Test Data

_Note: If you have already previously generated test data, you can skip this step._

Run with freshly generated points and save the test data
to a directory. Note that this overwrites anything you have in 'path/to/write/to'
without warning!

```bash
# The --nocapture flag will cause println! in rust to be displayed to the user
CMAKE=cmake3 XCLBIN=<file> TEST_NPOW=10 TEST_WRITE_DATA_TO=path/to/write/to cargo test --release -- --nocapture
```

For `TEST_NPOW=10`, this should run in a few seconds. For `TEST_NPOW=26`, it can take
around 6-7 hours to generate all the points.

### Running Tests

To load the points from disk, use the `TEST_LOAD_DATA_FROM` env-var. Note that
you don't have to specify `TEST_NPOW` when specifying `TEST_LOAD_DATA_FROM`.
(If you do, it will just be ignored)


The following command will time and verify the result for 4 rounds of
2<sup>26</sup> MSM, and run some unit tests:

```bash
# The --nocapture flag will cause println! in rust to be displayed to the user
CMAKE=cmake3 XCLBIN=<file> TEST_LOAD_DATA_FROM=path/to/load/from cargo test --release -- --nocapture
```

The expected runtime for a 2^26 test:

- around 5-10m to load the test data
- around 20-30m to run `multi_scalar_mult_init`, as it needs to convert all the points given to it
  into twisted edwards form.
- around 20s per MSM of batch size 4

Amongst the various outputs, one of them will show the latency of 4 rounds and
correctness:

```
$ CMAKE=cmake3 XCLBIN=~/afi-0938ad46413691732.awsxclbin TEST_LOAD_DATA_FROM=~/testdata/2_26 cargo test  --release -- --nocapture
Done internal format conversion!
Loading XCLBIN=/home/55312.bsdevlin.gmail.com/afi-0938ad46413691732.awsxclbin and doing openCL setups:
Found Platform
Platform Name: Xilinx
INFO: Reading /home/55312.bsdevlin.gmail.com/afi-0938ad46413691732.awsxclbin
Loading: '/home/55312.bsdevlin.gmail.com/afi-0938ad46413691732.awsxclbin'
Trying to program device[0]: xilinx_aws-vu9p-f1_shell-v04261818_201920_2
Device[0]: program successful!
[Copying input points to gmem] 1.4966s
multi_scalar_mult_init took Ok(1167.977275761s)
Running msm test for 1 rounds
Running MSM of [67108864] input points (4 batches)
Streaming input scalars across 4 chunks per batch (Mask IO and Post Processing)
Running multi_scalar_mult took Ok(20.37390268s) (round = 0)
test msm_correctness ... ok
```

For debugging some driver code, it's usually easier to test on a set of trivial
inputs (all points are G1 generator, all scalars are zero except for scalars[0]).
Test data for 2^26 takes <5s to generate on AWS.

```bash
CMAKE=cmake3 XCLBIN=<file> TEST_TRIVIAL_INPUTS=1 XCLBIN=<file> cargo test --release -- --nocapture
```

To run the tests on the FPGA box with freshly generated points. Note that if
you don't specify `TEST_NPOW`, the test harness will raise (this is different
from the original GPU test harness)

```bash
CMAKE=cmake3 XCLBIN=<file> TEST_NPOW=10 cargo test --release -- --nocapture
```

### Benchmarking

This is similar to running tests, except instead of running `cargo test`, you
run `cargo bench`. The expect environment variables are similar:

```bash
CMAKE=cmake3 \
  XCLBIN=<XCLBIN> \
  TEST_LOAD_DATA_FROM=~/testdata/2_26 \
  cargo bench
```

The output shows show the result of 10 runs of 4 rounds each:

```
FPGA-MSM/2**26x4 time: [20.336 s 20.336 s 20.337 s]
```

### Power

AWS allows the average power to be measured during operation. Run the following
command during the MSM evaluation to get a power measurement.

```
sudo fpga-describe-local-image -S 0 -M
```
```
Power consumption (Vccint):
   Last measured: 52 watts
   Average: 52 watts
   Max measured: 56 watts
```

### Breakdown of individual host steps

The breakdown of how long each stage takes can be printed when changed the value
of `mask_io` to `false` in `host/driver/driver.cpp` (this is not used in
benchmarking as it has lower performance):

```
[memcpy-ing scalars to special memory region] 0.28928s
[transferring scalars to gmem] 0.198263s
[Doing FPGA Computation] 4.96781s
[Copying results back from gmem] 0.00128217s
[Doing on-host postprocessing] 0.469954s
```

### Notes
 1. Because our solution offloads a non-trivial amount of work to the host
 to perform in parallel, you will see the best performance after a fresh reboot,
and without other CPU-intensive tasks running at the same time.
 2. When running the tests, if you terminate the binary early by `ctrl-c`, it
will leave the FPGA in a bad state which requires clearing and re-programming
with these commands:

## Debugging

### Running `host_buckets.exe` debug test

`host_buckets.exe` is a debug application that pumps test vectors into the FPGA
from a file, and compares against a reference file. Note this is NOT the
benchmarking program and has not been optimized at all.

Firstly, compile the host binaries:

```bash
cd host
mkdir build/
cd build/

# Need to explicitly use cmake3 in the aws box, since it's running a pretty old
# centos
cmake3 ..
make -j

# Now, generate the test vectors. This just needs to be done once. Here's an
# example for debugging with 50k points
dune build @../../hardcaml/bin/default
../../hardcaml/bin/tools.exe test-vectors \
  -num-points 50_000 \
  -input-filename inputs-50_000.txt \
  -output-filename outputs-50_000.txt \
  -seed 1

# Now, run the actual binary. It should say "TEST PASSED" in the end. If you
# see verbose test output with things that looks like coordinates, your test
# probably failed.
./driver/host_buckets \
  path/to/msm_pippenger.link.awsxclbin \
  inputs-50000.txt \
  outputs-50000.txt
```
