---
layout: default
title: ntt_build
category: ntt
subcategory: design
---

# Build Instructions

## Building the Verilog Files

We have done our RTL development in
[Hardcaml](https://github.com/janestreet/hardcaml), with bits of Vivado HLS
for writing C++ kernels to integrate with the Vitis platform. Hardcaml generates
Verilog files that can be fed into traditional vendor tools.

1. Clone the [github repository](http://github.com/fyquah/hardcaml_zprize)

2. Follow the instructions [to install opam](https://opam.ocaml.org/doc/Install.html)
, the OCaml package manager

3. Install the OCaml 4.13.1 compiler. You will need to run:

    ````
    opam switch create 4.13.1
    eval $(opam env)
    ```

4. Install the relevant OCaml dependencies. `opam install . --deps-only`

5. Now, from the root directory of this repository, navigate to
   `zprize/ntt`, and run `dune build @default`. This builds all the default
   targets which includes Verilog generation.

   (If you see an error message that says `package foo_bar_baz not found`, that's
   because we didn't specify the package list correctly. Please run
   `opam install foo_bar_baz` to install said package.)

6. (optional) Run `dune build @test` to validate that all our OCaml-level tests
   are working as expected. We have a lot of RTL testbenches written in OCaml.

## Setting Up the FPGA Build and Runtime Environment

Make sure you have the following packages installed:

- Vitis 2021.2 (with the [y2k22 HLS Patch](https://support.xilinx.com/s/article/76960?language=en_US))
- Xilinx XRT
- Installing the [development and deployment platforms and Varium C1100}](https://www.xilinx.com/products/accelerators/varium/c1100.html#gettingstarted)

We have tested our design and ran builds on a 6-core
Intel(R) Core(TM) i5-9600K CPU @ 3.70GHz machine with
`Ubuntu 22.04 LTS (GNU/Linux 5.15.0-48-generic x86_64)`.  We did not use
any special kernel flags / boot parameters to obtain our results.

## Building the FPGA Images

1. Make sure you have sourced `path/to/vitis/2021.2/settings64.sh` and
`path/to/xrt/setup.sh`

2. Now, navigate to the `zprize/ntt/fpga` subdirectory. You should see the
   following subdirectories:

    ```
    // directory containing C++ kernels for interfacing with memory.
    common

    // A very tiny NTT used for debugging
    ntt-2_12-normal_layout
    ntt-2_12-optimized-layout

    // The small NTT target used for the first phase of the competition
    ntt-2_18-normal_layout

    // The large NTTs for the performance contest
    ntt-2_24-normal_layout-8_cores
    ntt-2_24-normal_layout-16_cores
    ntt-2_24-normal_layout-32_cores
    ntt-2_24-normal_layout-64_cores
    ntt-2_24-optimized_layout-32_cores
    ntt-2_24-optimized_layout-64_cores

    // A debugging application, not relevant for submission
    reverse
    ```

3. cd into the directory with the build target you are interested in

4. Run `./compile_hw.sh`. This will kick off a build with Vitis that will
take around 2 hours to complete.

## Running Randomized Tests

1. Make sure you have sourced `path/to/xrt/setup.sh`.

2. Navigate to `zprize/ntt/test` relative to the root of the repository. You
   will see a lot of shell scripts.

3. Now, run `./test_random_ntt-2_24-<ARCH>-hw.sh`, depending on which
architecture you'd like to test. For example: to test on random test cases on
the 2^24 8-core build, run
`./test_random_ntt-2_24-normal_layout-8_cores-hw.sh`. This will invoke
compilation of some host binary and pass the appropriate flags.

4. As the test runs, you will see output that looks something like the following.
   This gives you a rough breakdown of the various components of the latency:

```
// Output from ./test_random_ntt-2_24-normal_layout-8_cores-hw.sh
<snip>
Run 2:
[Copy to internal page-aligned buffer] 0.00961825s
[Copying input points to device] 0.0401028s
[Doing NTT (phase1)] 0.110859s
[Doing NTT (phase2)] 0.120559s
[Copying final result to host] 0.0544204s
[Copy from internal page-aligned buffer] 0.0104411s
[Evaluate NTT] 0.346055s
Ok! (Time taken: 0.346058s)
<snip>
Test case[0]: PASSED
Test case[1]: PASSED
Test case[2]: PASSED
Test case[3]: PASSED
Test case[4]: PASSED
Test case[5]: PASSED
Test case[6]: PASSED
Test case[7]: PASSED
Test case[8]: PASSED
Test case[9]: PASSED

NTT TEST PASSED
```

5. If you'd like to run more tests, open the file and change the
   `--num-test-caes` flag to something bigger.

## Running Test against Test Files

1. Make sure you have installed Xilinx runtime `path/to/xrt/setup.sh`.

2. Navigate to `zprize/ntt/test` relative to the root of the repository. You
   will see a lot of shell scripts.

3. To test on test cases saved in files, run
`./test_given_ntt-2_24-<ARCH>-hw.sh path/to/input/file.txt path/to/expected/output.txt`
(e.g., `./test_given_ntt-2_24-normal_layout-64_cores-hw.sh`).  This will invoke
compilation of some host binaries and run them with the appropriate flags.

4. The test will report if it succeeded or failed. Note that the correctness
check is done using the `diff` command. Our test application writes the output
file in the format similar to the test data given at the start of the
competition. We have verified that this command works with the provided
test data.

```
$ ./test_given_ntt-2_24-normal_layout-64_cores-hw.sh ~/testdata/in/linear_2_24 ~/testdata/out/linear_2_24
make: Entering directory '/path/to/zprize/ntt/host'
make: 'evaluate_given.exe' is up to date.
make: Leaving directory '/path/to/zprize/ntt/host'
Running ntt-fpga test with
  binaryFile =  ../fpga/ntt-2_24-normal_layout-64_cores/build/build_dir.hw.xilinx_u55n_gen3x4_xdma_2_202110_1/ntt_fpga.xclbin
  core_type NTT_2_24
  log_row_size = 12
Found Platform
Platform Name: Xilinx
INFO: Reading ../fpga/ntt-2_24-normal_layout-64_cores/build/build_dir.hw.xilinx_u55n_gen3x4_xdma_2_202110_1/ntt_fpga.xclbin
Loading: '../fpga/ntt-2_24-normal_layout-64_cores/build/build_dir.hw.xilinx_u55n_gen3x4_xdma_2_202110_1/ntt_fpga.xclbin'
Trying to program device[0]: xilinx_u55n_gen3x4_xdma_base_2
Device[0]: program successful!
[Copy to internal page-aligned buffer] 0.00975602s
[Copying input points to device] 0.0526788s
[Doing NTT (phase1)] 0.0200124s
[Doing NTT (phase2)] 0.0249088s
[Copying final result to host] 0.0545655s
[Copy from internal page-aligned buffer] 0.0099347s
[Evaluate NTT] 0.171936s
Test succeeded!
```

## Benchmarking Latency

We provide scripts to benchmark latency. To run them:

1. Navigate to `zprize/ntt/fpga/test`

2. Run `./bench_latency_ntt-2_24-<ARCH>-hw.sh`, for eg:
`./bench_latency_ntt-2_24-normal_layout-8_cores-hw.sh`

3. You should see an output that looks something like this. The script
   might take a while to run as it goes through many test cases:

```
./bench_latency_ntt-2_24-normal_layout-8_cores-hw.sh
<snip>
Latency over 200 NTTs
-------
Mean latency: 0.23154s
-------
Min latency          : 0.231484s
25-percentile latency: 0.231531s
Median latency       : 0.23154s
75-percentile latency: 0.231549s
Max latency          : 0.231596s
```

(As per the competition specification, the test binary will measure FPGA-only
latency in cases where the host does not do any pre-post processing. In cases
which require pre/post-processing, it will measure the end-to-end latency)

## Known Limitations

These are not fundamental limitations, but rather features that we would want
for an actual product and haven???t had time to implement.

- We don't have a single design that can perform NTT for all sizes. We have a
  different firmware for each.
- The design is not very robust against Ctrl+c invocations (in the sense that
  it can start giving bad results after it's killed). Hence, when running
  test/benchmarking scripts, please let it finish rather than killing it!
- If you hit Ctrl+c and the design is not writing bad data, please run
  `xbutil reset -d <pcie-device-id>`. This will clear the FPGA image, and
  running the test scripts again will cause the `.xclbin` file to get flashed.
- We do not support multiple Unix processes accessing the core simultaneously.
