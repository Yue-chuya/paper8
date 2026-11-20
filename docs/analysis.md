# Analysis of Discrepancies



## 1. Overview

This project evaluates selected claims from the original AddressSanitizer (ASan) paper through memory-error detection tests and a reduced-scale GEMM performance experiment.

The current evidence supports two main observations:

1. ASan successfully detected the selected memory errors represented by the available test programs and logs.
2. Enabling ASan increased the execution time and peak memory usage of the tested GEMM workload.

However, our reproduction differs from the original paper in benchmark selection, experimental environment, and measurement scope. Therefore, the results should be interpreted as a reduced-scale reproduction rather than an exact reproduction of the original evaluation.

## 2. Claim Verdicts

### 2.1 Claim 1: Memory-Error Detection

**Claim:** AddressSanitizer can detect representative memory-safety errors, including heap buffer overflows and heap use-after-free.

**Verdict: Supported for the tested cases.**

The repository contains six ASan execution logs. Each log includes an explicit AddressSanitizer diagnostic identifying the corresponding memory error.

| Test | Log File | ASan Diagnostic | Result |
|---|---|---|---|
| Heap use-after-free | `logs/minimal_demo.log` | `heap-use-after-free` | Detected |
| Double-free | `logs/exp_double_free.log` | `attempting double-free` | Detected |
| Global out-of-bounds | `logs/exp_global.log` | `global-buffer-overflow` | Detected |
| Heap buffer overflow | `logs/exp_malloc_zero.log` | `heap-buffer-overflow` | Detected |
| Heap out-of-bounds | `logs/exp_oob.log` | `heap-buffer-overflow` | Detected |
| Stack buffer overflow | `logs/exp_stack.log` | `stack-buffer-overflow` | Detected |

The evidence demonstrates that ASan detected the intended errors in the available test programs.

**Important clarification:** The source file `experiments/exp_malloc_zero.c` allocates one byte using `malloc(1)` and then writes to `p[1]`. Therefore, this test demonstrates a heap buffer overflow, not an error caused by `malloc(0)`.

The current evidence supports the memory-error detection claim for the tested cases. It does not establish that every memory-error category discussed in the original paper has been reproduced.

### 2.2 Claim 2: Runtime Overhead

**Claim:** Enabling AddressSanitizer increases execution time compared with running the same workload without ASan.

**Verdict: Supported for the tested GEMM workload.**

The benchmark uses a self-contained GEMM implementation with matrix size N = 1000.

The recorded measurements are:

| Configuration | Run 1 (s) | Run 2 (s) | Run 3 (s) | Mean (s) | SD (s) |
|---|---:|---:|---:|---:|---:|
| Baseline | 1.584134 | 1.578419 | 1.486961 | 1.5498 | 0.0445 |
| ASan | 2.597861 | 2.602678 | 2.590914 | 2.5972 | 0.0048 |

According to `logs/benchmark_result.md`, the measured runtime ratio is approximately 1.68×, corresponding to a slowdown of 67.58%.

The ASan-enabled version therefore takes longer to execute than the baseline version under the tested workload.

The original paper reports an average slowdown of approximately 73% across SPEC CPU2006 benchmarks. Our measured slowdown is approximately 5.42 percentage points lower.

This difference should not be interpreted as a contradiction. Our experiment uses one self-contained GEMM workload rather than the original benchmark suite. The workload coverage and experimental environment are different.

**Conclusion:** The qualitative runtime-overhead claim is supported by our experiment. The exact 73% benchmark-suite average has not been reproduced.

### 2.3 Memory Overhead Observation

The benchmark log also records peak memory usage:

| Metric | Baseline | ASan |
|---|---:|---:|
| Mean Peak Memory | 24.38 MB | 61.44 MB |

The recorded memory ratio is approximately 2.52×.

This result indicates that the ASan-enabled GEMM process used more peak memory than the baseline process.

The original paper reports a memory increase of approximately 3.37×. However, the available project documentation does not establish that our peak-memory measurement uses exactly the same measurement definition and methodology as the original paper.

Therefore, the 2.52× result should be treated as an observation from our GEMM experiment, not as an exact reproduction of the paper's memory-overhead result.

## 3. Discrepancies from the Original Paper

| Item | Original Paper | Our Reproduction | Impact |
|---|---|---|---|
| Benchmark suite | SPEC CPU2006 | Self-contained GEMM | Limited workload coverage |
| Workload scale | Multiple benchmarks | One GEMM workload, N = 1000 | Results may not generalize to other applications |
| Runtime slowdown | Approximately 73% | 67.58% | Difference of approximately 5.42 percentage points |
| Memory overhead | Approximately 3.37× | 2.52× peak-memory ratio | Measurement methodology may differ |
| Implementation | ASan evaluated in the original paper | Existing Clang AddressSanitizer implementation | Uses an available implementation rather than reimplementing ASan |
| Experimental environment | HP Z600, 64-bit mode | macOS and Ubuntu WSL2 environments appear in the repository | Hardware and software environments differ |

The benchmark substitution is the most important limitation for interpreting the performance comparison. A single GEMM workload cannot represent the behavior of the complete SPEC CPU2006 suite.

## 4. Evidence Gaps and Issues Requiring Verification

Several details should be clarified before the final report.

1. **Experimental environment:** The benchmark documentation identifies Apple Silicon and macOS, while the earlier use-after-free notes identify Ubuntu 22.04 on WSL2. The environment should be documented separately for each experiment.

2. **Hardware details:** The current setup document lists multiple CPU models and operating systems together. The exact machine used for each experiment should be identified.

3. **Benchmark provenance:** The current source file is a self-contained `gemm.c` implementation with N = 1000. The report should not describe it as PolyBench/C 4.2.1 unless the group provides evidence of that benchmark source.

4. **Benchmark log generation:** The benchmark script writes to `logs/benchmark_result1.md`, whereas the repository currently contains `logs/benchmark_result.md`. The group should confirm the provenance of the committed result file.

5. **Starting commit:** The original starting commit cannot be identified from the downloaded ZIP because Git history is not included.

6. **Memory measurement:** The exact comparability of our peak-memory measurement and the original paper's memory-overhead metric remains unverified.

7. **Extension experiment:** The repository currently contains an extension design describing a change in heap redzone size from 128 bytes to 32 bytes. The design document alone does not provide experimental results.

## 5. Limitations

This reproduction has several limitations:

- It evaluates one GEMM workload rather than the full SPEC CPU2006 benchmark suite.
- It uses the existing Clang AddressSanitizer implementation rather than reimplementing the original system.
- The experiments appear to have been conducted across different operating-system environments.
- The memory-overhead measurement may not use the same methodology as the original paper.
- The extension experiment is documented as a design, but its experimental results are not present in the current repository.
- The historical Chromium bug-finding results reported in the original paper were not independently reproduced.

## 6. Overall Assessment

The current experiments support the selected qualitative claims that AddressSanitizer detects the tested memory errors and introduces runtime overhead.

The GEMM experiment records a runtime slowdown of 67.58% and a peak-memory ratio of 2.52×. These results demonstrate measurable overhead in the selected workload.

However, the reproduction does not reproduce the original paper's complete SPEC CPU2006 evaluation or establish an exact comparison of memory-overhead methodology.

Overall, the project should be described as a **partial, reduced-scale reproduction** of selected AddressSanitizer claims.

