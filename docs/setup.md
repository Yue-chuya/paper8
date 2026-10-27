# Experimental Setup and Reproduction Plan

> **Status:** Initial plan — update this document as the group confirms the environment and runs experiments.  
> **Purpose:** Record the scope, setup, procedure, and measurements for our reduced-scale reproduction of *AddressSanitizer: A Fast Address Sanity Checker* (USENIX ATC 2012).

## 1. Paper and Reproduction Goal

**Paper:** *AddressSanitizer: A Fast Address Sanity Checker*, USENIX Annual Technical Conference (USENIX ATC), 2012.

This project evaluates selected claims from the paper using the available AddressSanitizer (ASan) implementation provided by Clang/LLVM. The goal is a **reduced-scale reproduction**, not a reimplementation of ASan itself. We will document any differences between our experiments and the original paper.

## 2. Claims to Test

We plan to investigate the following claims:

1. **Memory-error detection:** ASan can detect representative memory-safety errors, including heap buffer overflows and heap use-after-free.
2. **Runtime overhead:** Enabling ASan increases execution time compared with running the same workload without ASan. We will measure the overhead in our selected workload and compare the result with the paper's reported average slowdown of approximately 73%.

These are selected claims rather than a complete reproduction of every experiment in the original paper. Results will be described as *supported*, *partially supported*, *not supported*, or *inconclusive*, based on the evidence collected.

## 3. Scope and Limitations

- Use the existing Clang/LLVM ASan implementation; do not attempt to reimplement the sanitizer.
- Implement small, controlled test programs for the selected memory-error cases.
- Run a workload with and without ASan to measure runtime overhead.
- Repeat timing measurements at least **three times** for each configuration.
- Report the mean and standard deviation of the measurements.
- Keep source code, scripts, raw logs, and result summaries in the GitHub repository so that reported numbers can be traced to evidence.
- This is a reduced-scale study. Its benchmark coverage and scale may differ substantially from those of the original paper.

## 4. Experimental Environment

Fill in the actual values after checking the machine used for the experiments. Do not leave guessed values in the final report.

| Item | Value |
|---|---|
| Operating system and version | TBD |
| CPU model | TBD |
| RAM | TBD |
| Compiler and version (`clang --version`) | TBD |
| ASan availability / runtime version | TBD |
| Build tools and versions | TBD |
| Repository URL and starting commit | TBD |
| Date of experiment | TBD |

### Environment collection commands

Run these commands in the environment used for the experiments and record the relevant output:

```bash
uname -a
clang --version
clang++ --version
```

On Linux, the following may also help identify the processor and memory:

```bash
lscpu
free -h
```

If a command is unavailable on the operating system, record that fact instead of inventing a value.

## 5. Workloads and Inputs

### 5.1 Heap buffer overflow test

Create a small C/C++ program that deliberately accesses memory outside a heap allocation. Compile it with ASan enabled and run it. The expected observation is an ASan diagnostic identifying a heap-buffer-overflow. This program is intended to test detection, not to produce a valid performance measurement.

### 5.2 Heap use-after-free test

Create a small C/C++ program that accesses heap memory after it has been freed. Compile it with ASan enabled and run it. The expected observation is an ASan diagnostic identifying a heap-use-after-free.

For both error tests, save the source code, compiler command, exit status, and relevant diagnostic output. Exact output may vary with compiler version and platform.

### 5.3 Runtime-overhead workload

Use the same deterministic workload and input for both configurations:

- **Baseline:** compile and run without ASan.
- **ASan:** compile and run with ASan enabled.

Keep the workload, input, optimization level, and other relevant build settings the same wherever possible. Record the exact commands and runtime output. Avoid using the intentional-crash test programs as the performance workload.

The specific benchmark and input size are **TBD** and must be agreed upon by the group before collecting final measurements.

## 6. Procedure

1. Record the environment details listed in Section 4.
2. Record the repository URL, starting commit, and source files used or modified.
3. Build and run the heap buffer overflow test with ASan enabled.
4. Build and run the heap use-after-free test with ASan enabled.
5. Select and document a deterministic performance workload and input.
6. Build the performance workload without ASan and with ASan, keeping other settings consistent.
7. Run each configuration at least three times under comparable conditions.
8. Save raw timing results and logs for every run.
9. Calculate the mean and standard deviation for each configuration.
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

| Workload | Configuration | Run 1 | Run 2 | Run 3 | Mean | Standard deviation |
|---|---|---:|---:|---:|---:|---:|
| TBD | Baseline (ASan off) | TBD | TBD | TBD | TBD | TBD |
| TBD | ASan enabled | TBD | TBD | TBD | TBD | TBD |

### Suggested claim assessment

| Claim | Evidence to collect | Assessment |
|---|---|---|
| ASan detects heap buffer overflow | Source, command, and diagnostic log | Not yet assessed |
| ASan detects heap use-after-free | Source, command, and diagnostic log | Not yet assessed |
| ASan introduces runtime overhead for the selected workload | At least 3 runs per configuration and summary statistics | Not yet assessed |
| Our measured slowdown is close to the paper's reported average of approximately 73% | Comparable metric and clear discussion of workload differences | Not yet assessed |

## 8. Extension Experiment

If time permits, compare two optimization levels (for example, `-O0` and `-O2`) while changing only the optimization level. For each level, compare the baseline and ASan-enabled builds using the same workload and input, with at least three runs per configuration.

Record the exact compiler flags. Discuss whether optimization level changes the measured overhead. This extension is optional until the group confirms it can be completed.

## 9. Deviations from the Original Paper

This project is a reduced-scale reproduction. The following details must be completed after the implementation and experiments are finalized:

- **Benchmarks used:** TBD
- **Input sizes and workloads:** TBD
- **Hardware and software differences:** TBD
- **Original-paper experiments not reproduced:** We do not aim to reproduce every benchmark or reimplement ASan.
- **Other deviations or constraints:** TBD

The final report should explain how these deviations affect the strength and generality of the conclusions.

## 10. Reproducibility Checklist

- [ ] Environment details recorded from the actual machine.
- [ ] Repository URL and starting commit recorded.
- [ ] Source files and modifications documented.
- [ ] Workload and input fixed and described.
- [ ] Exact compiler commands and flags saved.
- [ ] Both memory-error tests run and logs saved.
- [ ] Baseline and ASan configurations measured at least three times.
- [ ] Mean and standard deviation calculated.
- [ ] Charts and result tables generated from recorded data.
- [ ] Each reported number traceable to a log or calculation.
- [ ] Claim assessments and discrepancies documented.
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
