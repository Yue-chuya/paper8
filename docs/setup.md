# Reproduction Setup

## 1. Starting Code
This project reproduces selected claims of *AddressSanitizer: A Fast Address Sanity Checker* (USENIX ATC 2012) using the existing Clang/LLVM AddressSanitizer implementation rather than reimplementing ASan from scratch. Because the original paper did not provide a standalone replication repository, our replication relies on the Clang/LLVM toolchain's built-in ASan instrumentation and runtime library.

* **Replication Repository:** `https://github.com/Yue-chuya/paper8`
* **Starting Commit:** `d6ae8027d02cb2a378a026d46080c5737d2d1ec0`
* **Upstream Paper & Tool Reference:** Paper PDF (`https://www.usenix.org/system/files/conference/atc12/atc12-final39.pdf`) and Clang AddressSanitizer documentation (`https://clang.llvm.org/docs/AddressSanitizer.html`, part of LLVM under the Apache License v2.0 with LLVM Exception)
* **Modified / Added Files:**
  * Build & documentation: `Makefile`, `README.md`, `docs/*.md`
  * Workloads, bug/false-negative tests & extension design: `experiments/workload/*.c`, `experiments/bug_tests/*.c`, `experiments/false_negative/*.c`, `extension/extension_design.md`
  * Automation & plotting scripts: `scripts/*.sh`, `scripts/*.py`

## 2. Environment
To reproduce the experiments on a clean machine without hard-coded paths, ensure the following platforms and tools are available:

* **Supported Platforms**
  1. Linux (Ubuntu 22.04 on WSL2)
     * Kernel `6.18.54.1-microsoft-standard-WSL2`
     * clang `21.1.8 (6ubuntu1)`
     * GNU Make `4.4.1`, GNU Bash `5.3.9(1)-release`
     * `16 GB` RAM (CPU: 13th Gen Intel(R) / AMD Ryzen 5 4500U)
  2. macOS (Apple Silicon)
     * Kernel `21.6.0 (Darwin)`
     * clang `14.0.0`
     * GNU Make `3.81`, GNU Bash `3.2.57(1)-release`
     * `8 GB` RAM (CPU: Apple M2)
* **Python environment (for plotting)**
  * Python 3 with numpy and matplotlib: `pip install numpy matplotlib`
* **Key Settings Affecting Results**
  * Performance benchmark builds use `-O2` (baseline) and `-O2 -fsanitize=address` (ASan).
  * Bug detection and false-negative tests use `-O0 -fsanitize=address -g` to prevent compiler dead-code or undefined-behavior optimizations from removing injected faults prior to instrumentation.
  * Paper-parameter runs: `ASAN_OPTIONS="quarantine_size_mb=0:redzone=32:malloc_context_size=0"`

### Experimental Environment Details

| Item | Value |
|---|---|
| CPU model | 13th Gen Intel(R) & AMD Ryzen 5 4500U & Apple M2 |
| RAM | 16GB |
| Operating system and version | Ubuntu 22.04(WSL2) & macOS |
| Kernel version | 6.18.54.1-microsoft-standard-WSL2 & 21.6.0 (Darwin) |
| Compiler | Ubuntu clang version 21.1.8 (6ubuntu1) & Apple clang |
| Build tools and versions | WSL2: GNU Make 4.4.1, GNU bash 5.3.9(1)-release; macOS: GNU Make 3.81, GNU bash 3.2.57(1)-release |
| Baseline compilation flags | -O2 |
| ASan compilation flags (Performance benchmark) | -O2 -fsanitize=address |
| ASan compilation flags (Bug detection tests) | -O0 -fsanitize=address[cite: 29]

## 3. Workloads
Because the commercial SPEC CPU2006 suite was unavailable for this project, we use a self-contained C workload and targeted test suites implemented in the repository:

* **Performance Workload (`experiments/workload/gemm.c`):** Dense matrix multiplication (`1000 × 1000`, $O(N^3)$) written in standard C with deterministic row/column-index initialization (no external input files or RNG), occupying ~24 MB across three double-precision arrays and taking ~1.5 s per run (`clock_gettime(CLOCK_MONOTONIC)` over the multiplication phase)
* **Bug & False-Negative Suites:** Small C programs under `experiments/bug_tests/` (UAF, Double-Free, Heap/Stack/Global OOB) and `experiments/false_negative/` (unaligned access, far OOB beyond redzones, quarantine exhaustion)
* **Multi-Threaded Extension Workload (`extension/extension_design.md`):** Multi-threaded GEMM (`pthreads` across `1`, `2`, `4`, and `8` threads under `-O2 -pthread` vs. `-O2 -pthread -fsanitize=address`) keeping total matrix work constant[cite: 11, 12, 17, 18]

For full workload details, see `docs/workload.md`.

## 4. Deviations
The table below summarizes key differences from the original paper's experimental setup (Section 4); full details are recorded in `docs/deviations.md`:

| Dimension | Original Setting (Paper) | Our Setting (Reproduction) | Reason |
|---|---|---|---|
| **Benchmark Suite** | SPEC CPU2006 (20+ C/C++ programs) | Self-contained `gemm.c` (`N=1000`) | Commercial licensing restriction; GEMM provides a controlled, deterministic substitute |
| **Hardware & OS** | HP Z600 (2× quad-core Xeon E5620, 24 GB RAM), 64-bit bare-metal Linux | Apple M2 (8 GB) / macOS & WSL2 (16 GB, Intel/Ryzen) / Ubuntu 22.04 | Local student hardware and OS environments |
| **Compiler & Flags** | LLVM Clang (~2011–2012, LLVM 3.1+ era), `-O2` | Apple Clang 14.0.0 & Ubuntu Clang 21.1.8; `-O2` for perf, `-O0 -g` for fault/FN tests | Modern compiler optimizations and preventing `-O2` from removing intentional bugs |
| **ASan Runtime Params** | `quarantine_size_mb=0:redzone=32:malloc_context_size=0` (defaults: 256MB / 128B / depth 30) | Both Default ASan settings and Paper's exact parameters | Compare against paper parameters while also checking realistic default runtime settings |
| **Bug & FN Testing** | 3 bugs in SPEC CPU2006, 300+ bugs in Chromium; Section 3.5 theoretical FN analysis | 5 micro C bug tests & empirical test cases for all 3 FN scenarios | Chromium scale is infeasible; micro-tests isolate bugs and validate Section 3.5 limits |
| **Extension & Scope** | Single-threaded Section 4 eval; also `writes-only` (26%), `Scale`/`Offset`, `VmStk`, binary size (1.5x–3.2x), tool comparisons | Added `pthreads` GEMM scaling (`1, 2, 4, 8` threads); omitted secondary paper metrics | Explore multi-core scaling while keeping scope focused on core claims |
| **Execution & Stats** | Reported per-benchmark / aggregate ratios and `/proc/self/status` (`VmPeak`, `VmStk`) | Automated `Makefile`/scripts over 3 runs (`min_s`, `mean_s`, std, slowdown, speedup, peak RSS) | Reproducibility, variance control, and automated output in `results/` and `figure/`