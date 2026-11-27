# Results

## 1. Comparison: Original Paper vs. Our Reproduction

The following table compares the performance overhead reported in the original AddressSanitizer (ASan) paper with the results obtained from our reproduction. We present two sets of experimental results: the default Benchmark configuration and the Paper Params configuration, which uses the ASan evaluation parameters specified in the original paper.

| Metric | Original Paper (SPEC CPU2006) | Our Benchmark (Default) | Our Reproduction (Paper Params) |
| :--- | :--- | :--- | :--- |
| **Runtime Slowdown** | ~73% (1.73x) | **74.50% (1.75x)** | **68.81% (1.69x)** |
| **Memory Overhead** | ~3.37x | **2.51x** | **2.51x** |

The Paper Params configuration uses the following environment variable:

`ASAN_OPTIONS="quarantine_size_mb=0:redzone=32:malloc_context_size=0"`

The comparison between the two configurations allows us to examine the effect of applying the paper's specified ASan parameters. Although our GEMM workload differs from the SPEC CPU2006 benchmarks used in the original paper, the results provide a comparison of ASan overhead under different configurations.

## 2. Statistics: Mean ± Standard Deviation

The statistical results are calculated from three runs for each configuration. Both Baseline and ASan execution times are reported to show runtime performance under each setting.

### 2.1 Benchmark (Default Configuration)

- **Baseline Runtime (ASan OFF):** 1.4939 s ± 0.0022 s
- **ASan Runtime (ASan ON):** 2.6069 s ± 0.0592 s
- **Runtime Ratio:** 1.75x
- **Runtime Slowdown:** 74.50%
- **Baseline Peak Memory:** 24.35 MB
- **ASan Peak Memory:** 61.10 MB
- **Memory Ratio:** 2.51x

### 2.2 Paper Params Configuration

- **Baseline Runtime (ASan OFF):** 1.5206 s ± 0.0229 s
- **ASan Runtime (ASan ON):** 2.5669 s ± 0.0027 s
- **Runtime Ratio:** 1.69x
- **Runtime Slowdown:** 68.81%
- **Baseline Peak Memory:** 24.33 MB
- **ASan Peak Memory:** 60.99 MB
- **Memory Ratio:** 2.51x

The results show that the Paper Params configuration achieved a lower runtime slowdown than the default Benchmark configuration (68.81% compared with 74.50%). Both configurations showed the same memory ratio of 2.51x.

## 3. Traceability

All reported results are traceable to the raw experimental data and execution logs stored in the project repository.

- **Raw timings and statistical results:** Recorded in `results/benchmark_result.md` and `results/paper_params_result.md`.
- **Execution logs:** Preserved in the `logs/` directory, including the corresponding Benchmark and Paper Params runs.
- **Original paper results:** The reference values are taken from the original AddressSanitizer paper.

These records allow the experimental results to be checked and reproduced.