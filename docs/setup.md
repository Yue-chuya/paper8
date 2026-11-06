# Experimental Setup and Reproduction Plan

> **Status:** Updated with the group's current environment and preliminary PolyBench/C GEMM measurements. Items not yet verified remain marked TBD.  
> **Purpose:** Record the scope, setup, procedure, and measurements for our reduced-scale reproduction of *AddressSanitizer: A Fast Address Sanity Checker* (USENIX ATC 2012).

## 1. Paper and Reproduction Goal

**Paper:** *AddressSanitizer: A Fast Address Sanity Checker*, USENIX Annual Technical Conference (USENIX ATC), 2012.

This project evaluates selected claims from the paper using the available AddressSanitizer (ASan) implementation provided by Clang/LLVM. The goal is a **reduced-scale reproduction**, not a reimplementation of ASan itself. For the runtime-overhead experiment, we use the GEMM matrix-multiplication benchmark from PolyBench/C 4.2.1 because SPEC CPU2006 was unavailable to the group due to licensing/access restrictions. We document this and other differences from the original paper.

## 2. Claims to Test

We plan to investigate the following claims:

1. **Memory-error detection:** ASan can detect representative memory-safety errors, including heap buffer overflows and heap use-after-free.
2. **Runtime overhead:** Enabling ASan increases execution time compared with running the same workload without ASan. We will measure the overhead in our selected workload and compare the result with the paper's reported average slowdown of approximately 73%.

For the runtime-overhead claim (the paper's reported approximately 73% average slowdown), our current GEMM result is approximately 68.6% slowdown. This is numerically close, but the assessment remains preliminary because it is based on one supplied timing per configuration and a different, reduced-scale benchmark. We therefore do not label the claim unconditionally *Supported* until repeated measurements and the workload limitation are documented.

These are selected claims rather than a complete reproduction of every experiment in the original paper. Results will be described as *supported*, *partially supported*, *not supported*, or *inconclusive*, based on the evidence collected. The current GEMM timing result is preliminary because only one timing value per configuration has been provided; repeated runs are still needed for a stronger assessment.

## 3. Scope and Limitations

- Use the existing Clang/LLVM ASan implementation; do not attempt to reimplement the sanitizer.
- Implement small, controlled test programs for the selected memory-error cases.
- Run a workload with and without ASan to measure runtime overhead.
- Repeat timing measurements at least **three times** for each configuration.
- Report the mean and standard deviation of the measurements.
- Keep source code, scripts, raw logs, and result summaries in the GitHub repository so that reported numbers can be traced to evidence.
- This is a reduced-scale study. Its benchmark coverage and scale may differ substantially from those of the original paper.

## 4. Experimental Environment

To ensure the reproducibility of the results, all experiments were conducted on a standardized environment. The exact configurations are detailed below.

| Item | Value |
|---|---|
| CPU model | 13th Gen Intel(R) & AMD Ryzen 5 4500U & Apple M2 |
| RAM | 16GB |
| Operating system and version| Ubuntu 22.04(WSL2) & macOS |
| Kernel version | 6.18.54.1-microsoft-standard-WSL2 & 21.6.0 (Darwin) |
| Compiler | Ubuntu clang version 21.1.8 (6ubuntu1) & Apple clang | 
| Build tools and versions | WSL2: GNU Make 4.4.1, GNU bash 5.3.9(1)-release; macOS: GNU Make 3.81, GNU bash 3.2.57(1)-release |
| Baseline compilation flags | -O2 |
| ASan compilation flags | -O2 -fsanitize=address |

## 5. Workloads and Inputs

### 5.1 Heap buffer overflow test

Create a small C/C++ program that deliberately accesses memory outside a heap allocation. Compile it with ASan enabled and run it. The expected observation is an ASan diagnostic identifying a heap-buffer-overflow. This program is intended to test detection, not to produce a valid performance measurement.

### 5.2 Heap use-after-free test

Create a small C/C++ program that accesses heap memory after it has been freed. Compile it with ASan enabled and run it. The expected observation is an ASan diagnostic identifying a heap-use-after-free.

For both error tests, save the source code, compiler command, exit status, and relevant diagnostic output. Exact output may vary with compiler version and platform.

### 5.3 Runtime-overhead workload

Use the GEMM matrix-multiplication benchmark from **PolyBench/C 4.2.1** for the runtime-overhead experiment. The same benchmark and input configuration should be used for both builds:

- **Baseline:** compile with `-O2` and without ASan.
- **ASan:** compile with `-O2 -fsanitize=address`.

The optimization level is kept the same so that the comparison focuses on the effect of enabling ASan. The group selected PolyBench/C GEMM instead of SPEC CPU2006 because SPEC CPU2006 was not available to the group due to licensing/access restrictions. The exact GEMM dataset/input size and full compile/run commands should still be recorded if they are not already preserved in the experiment logs. Avoid using the intentional-crash test programs as the performance workload.

## 6. Procedure

1. Record the environment details listed in Section 4.
2. Record the repository URL, starting commit, and source files used or modified.
3. Build and run the heap buffer overflow test with ASan enabled.
4. Build and run the heap use-after-free test with ASan enabled.
5. Use PolyBench/C 4.2.1 GEMM as the performance workload and record its input size/configuration.
6. Build the baseline with `-O2` and the ASan version with `-O2 -fsanitize=address`, keeping other settings consistent.
7. The currently supplied measurements are one timing result per configuration. For a stronger final result, repeat each configuration at least three times under comparable conditions.
8. Save raw timing results and logs for every run.
9. Once repeated measurements are available, calculate the mean and standard deviation for each configuration. Do not report a standard deviation from the current single measurements.
10. Calculate the slowdown using the same runtime metric for both configurations:

   `slowdown (%) = ((mean_ASan_runtime - mean_baseline_runtime) / mean_baseline_runtime) * 100`

11. Compare our result with the paper's reported average slowdown of approximately 73%, while clearly noting that our reduced workload is not necessarily comparable to the paper's full benchmark suite.
12. Interpret each tested claim and document discrepancies, limitations, and possible sources of measurement noise.

## 7. Results and Evidence to Preserve

The repository should contain, where applicable:

- Test program source files.
- Build/run scripts or exact commands.
- Raw logs from each run.
- A results table containing each individual runtime measurement.
- Summary statistics (mean and standard deviation).
- Charts comparing baseline and ASan-enabled runs.
- A short explanation linking every reported number to its source log or calculation.

Do not enter expected values as if they were measured results. Until experiments are run, results should be marked **Not yet measured**.

### Suggested results table

| Workload | Configuration | Current measured runtime | Mean | Standard deviation |
|---|---|---:|---:|---:|
| PolyBench/C 4.2.1 GEMM | Baseline (`-O2`, ASan off) | 1.18 s | Not available (one measurement supplied) | Not available |
| PolyBench/C 4.2.1 GEMM | ASan (`-O2 -fsanitize=address`) | 1.99 s | Not available (one measurement supplied) | Not available |

From the supplied measurements:

- Runtime ratio: `1.99 / 1.18 ≈ 1.69×`.
- Slowdown relative to baseline: `((1.99 - 1.18) / 1.18) × 100 ≈ 68.6%`.
- The paper reports an average slowdown of approximately 73% (about `1.73×`).

These values are based on one supplied timing per configuration. Repeat runs and raw logs should be added before treating the result as a final statistical measurement.

### Suggested claim assessment

| Claim | Evidence to collect | Assessment |
|---|---|---|
| ASan detects heap buffer overflow | Source, command, and diagnostic log | Not yet assessed |
| ASan detects heap use-after-free | Source, command, and diagnostic log | Not yet assessed |
| ASan introduces runtime overhead for the selected workload | GEMM timing: 1.18 s baseline vs. 1.99 s ASan (one supplied measurement per configuration); repeat runs still needed | Preliminary evidence supports overhead; strengthen with repeated runs |
| Our measured slowdown is close to the paper's reported average of approximately 73% | Calculated slowdown ≈ 68.6% (≈ 1.69×), compared with paper's ≈ 73% (≈ 1.73×); workload differs | Preliminary result is close to the paper's figure, but not enough by itself for an unqualified final “Supported” assessment |

## 8. Extension Experiment

Proposed extension: use the same PolyBench/C 4.2.1 GEMM workload and input to compare optimization levels `-O0` and `-O2`. At each optimization level, measure both configurations:

- Baseline: `-O0` or `-O2`.
- ASan: `-O0 -fsanitize=address` or `-O2 -fsanitize=address`.

Change only the optimization level between the two sets of experiments; keep the workload, input, and other settings consistent. Repeat each configuration at least three times if possible. Record the exact compiler commands and discuss whether optimization level changes the measured ASan overhead. This extension is a proposal and should be marked complete only after the experiments are actually run.

## 9. Deviations from the Original Paper

This project is a reduced-scale reproduction. The following details must be completed after the implementation and experiments are finalized:

- **Benchmarks used:** PolyBench/C 4.2.1 GEMM (matrix multiplication) is used for the runtime-overhead experiment instead of SPEC CPU2006.
- **Reason for benchmark substitution:** SPEC CPU2006 was not available to the group because of licensing/access restrictions.
- **Input sizes and workloads:** GEMM is the selected workload; the exact dataset/input size still needs to be recorded.
- **Hardware and software differences:** Ubuntu on WSL2 and Ubuntu clang version 21.1.8 are used; CPU, RAM, Ubuntu release, kernel, and build-tool details remain TBD until recorded from the test machine.
- **Scale and coverage:** This is a reduced-scale reproduction using one PolyBench/C benchmark rather than the original paper's broader benchmark suite.
- **Original-paper experiments not reproduced:** We do not aim to reproduce every benchmark or reimplement ASan.
- **Other deviations or constraints:** The current timing comparison contains one supplied measurement per configuration; repeated measurements are still needed.

The final report should explain how these deviations affect the strength and generality of the conclusions.

## 10. Reproducibility Checklist

- [ ] Environment details recorded from the actual machine.
- [ ] Repository URL and starting commit recorded.
- [ ] Source files and modifications documented.
- [x] Workload family selected: PolyBench/C 4.2.1 GEMM (record exact input size/configuration).
- [x] Optimization level and sanitizer flags recorded: baseline `-O2`; ASan `-O2 -fsanitize=address`.
- [ ] Full compiler commands and raw logs saved.
- [ ] Both memory-error tests run and logs saved.
- [ ] Baseline and ASan configurations repeated at least three times.
- [ ] Mean and standard deviation calculated from repeated measurements.
- [ ] Charts and result tables generated from recorded data.
- [ ] Each reported number traceable to a log or calculation.
- [x] Benchmark substitution and current preliminary slowdown comparison documented.
- [ ] Final claim assessments and discrepancies confirmed after repeated measurements.
- [ ] Optional extension completed or explicitly reported as not completed.

## 11. Group Contributions

This document records the experimental setup and reproduction plan. Update this section to reflect the actual work performed by each group member before final submission.

- Experimental setup and reproduction plan: TBD
- Test programs and execution scripts: TBD
- Benchmarking and analysis: TBD
- Report and presentation: TBD

## 12. References

1. *AddressSanitizer: A Fast Address Sanity Checker*. USENIX Annual Technical Conference (USENIX ATC), 2012.
2. Clang documentation, AddressSanitizer: https://clang.llvm.org/docs/AddressSanitizer.html

---

**Maintenance note:** Update this file when the group makes a concrete decision or completes an experiment. Replace `TBD` and `Not yet measured` only with verified information. This setup document supports the final report; it is not a substitute for the final report PDF or presentation.

