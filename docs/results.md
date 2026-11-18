# Experimental Results and Paper vs. Ours Comparison

> **Status:** Week 3 Draft  
> This document summarizes the group's current experimental results, including runtime overhead measurements and selected memory-error detection tests. Results are limited to the evidence currently available in the repository.

## 1. Experimental Configuration

| Item | Original Paper | Our Reproduction |
|---|---|---|
| Tool | AddressSanitizer (ASan) | Clang AddressSanitizer |
| Benchmark | SPEC CPU2006 C/C++ benchmarks | GEMM matrix multiplication |
| Benchmark size | Multiple SPEC CPU2006 benchmarks | N = 1000 |
| Baseline optimization | `-O2` | `-O2` |
| ASan compilation | ASan-instrumented binary | `-O2 -fsanitize=address` |
| Operating environment | 64-bit mode on HP Z600 | Ubuntu 22.04 on WSL2 |
| Compiler | LLVM-based compiler | Ubuntu Clang 21.1.8 |
| Runtime evaluation | Average across SPEC CPU2006 benchmarks | Three runs of one GEMM workload |

The original paper used the SPEC CPU2006 benchmark suite. Our group used a self-contained GEMM workload because SPEC CPU2006 was unavailable to the group.

This substitution reduces the scope of the reproduction. A single GEMM workload cannot represent the performance characteristics of the complete SPEC CPU2006 benchmark suite.

## 2. Runtime Performance Results

### 2.1 Three-Run Measurements

The following measurements are recorded in the group's `experiments/workload/workload.md`.

| Configuration | Run 1 (s) | Run 2 (s) | Run 3 (s) | Mean (s) | Sample SD (s) |
|---|---:|---:|---:|---:|---:|
| Baseline (ASan OFF) | 1.298579 | 1.285835 | 1.320533 | 1.3016 | 0.0146 |
| ASan (ASan ON) | 2.330606 | 2.329792 | 2.442241 | 2.3675 | 0.0526 |

The means and sample standard deviations above are recalculated from the three recorded measurements. Sample standard deviation uses the denominator n − 1.

**Note:** The standard deviations previously recorded in `workload.md` (0.0146 s and 0.0526 s) do not match the recalculated sample standard deviations. The group should confirm the required convention and update `workload.md` consistently.

### 2.2 Runtime Ratio

The runtime ratio is calculated as:

```text
Runtime Ratio = Mean ASan Runtime / Mean Baseline Runtime

              = 2.367546 / 1.301649

              ≈ 1.82×
```

### 2.3 Runtime Slowdown

The slowdown is calculated as:

```text
Slowdown (%) = ((Mean ASan Runtime - Mean Baseline Runtime)
                / Mean Baseline Runtime) × 100%

             = ((2.367546 - 1.301649) / 1.301649) × 100%

             ≈ 81.9%
```

The ASan-enabled GEMM workload therefore takes approximately 1.82 times as long as the baseline workload, corresponding to an approximately 81.9% runtime slowdown.

### 2.4 Comparison with the Original Paper

The original paper reports an average runtime slowdown of approximately 73% across the SPEC CPU2006 benchmark suite, equivalent to a runtime ratio of approximately 1.73×.

Our measured GEMM slowdown is approximately 81.9%, which is about 8.9 percentage points higher than the paper's reported average.

The result supports the qualitative observation that enabling ASan introduces runtime overhead. However, it does not reproduce the exact 73% average reported in the original paper because the benchmark workload and evaluation scope are different.

**Assessment:** The qualitative runtime-overhead claim is supported by our experiment. The original paper's exact benchmark-suite average has not been reproduced.

## 3. Memory-Error Detection Results

In addition to the runtime experiment, the group conducted selected memory-error detection tests using AddressSanitizer.

### 3.1 Heap Use-After-Free

The group's earlier experiment record in `experiments/notes.md` reports the following diagnostic:

```text
ERROR: AddressSanitizer: heap-use-after-free
READ of size 4
```

This indicates that ASan detected an attempt to read memory after the allocated heap memory had been freed.

**Result:** The recorded heap-use-after-free test was detected by ASan.

### 3.2 Double-Free Detection

The group conducted three boundary test runs. The following raw log files were examined:

- `logs/boundary_run1.log`
- `logs/boundary_run2.log`
- `logs/boundary_run3.log`

All three logs contain the diagnostic:

```text
ERROR: AddressSanitizer: attempting double-free
SUMMARY: AddressSanitizer: double-free
ABORTING
```

The results are summarized below:

| Run | ASan Diagnostic | Result |
|---|---|---|
| Boundary Run 1 | `attempting double-free` | Detected |
| Boundary Run 2 | `attempting double-free` | Detected |
| Boundary Run 3 | `attempting double-free` | Detected |

**Result:** AddressSanitizer successfully detected the tested double-free error in all three recorded runs (3/3).

The logs also contain warnings about an invalid external symbolizer path. These warnings may affect the readability of symbolized stack traces, but the explicit double-free diagnostic still identifies the detected error.

### 3.3 Other Memory-Error Tests

The group's Week 2 summary mentions additional test cases, including `malloc(0)` and heap out-of-bounds.

However, the three uploaded boundary logs examined for this report contain double-free diagnostics. They do not establish successful detection of these other cases.

| Test Case | Current Evidence | Status |
|---|---|---|
| Heap use-after-free | ASan diagnostic recorded in `experiments/notes.md` | Detected |
| Double-free | Three raw logs report `attempting double-free` | Detected (3/3 runs) |
| Heap out-of-bounds | No confirming raw diagnostic currently available | Pending verification |
| `malloc(0)` | No confirming raw diagnostic currently available | Pending verification |

These pending cases should not be reported as successful until their corresponding source code and raw execution logs have been checked.

## 4. Deviations from the Original Paper

| Item | Original Paper | Our Reproduction | Impact |
|---|---|---|---|
| Benchmark suite | SPEC CPU2006 C/C++ benchmarks | GEMM workload, N = 1000 | Reduced benchmark coverage |
| Runtime evaluation | Average across multiple benchmarks | One GEMM workload with three runs | Results are not directly equivalent |
| Runtime slowdown | Approximately 73% | Approximately 81.9% | Qualitative overhead is observed, but the numerical result differs |
| Memory-error tests | Multiple memory-error categories | Currently verified use-after-free and double-free cases | Only selected error cases are demonstrated |
| Symbolizer | Detailed diagnostic output | External symbolizer path warnings appear in logs | Stack-trace readability may be affected |
| Memory overhead | Approximately 3.4× reported in the paper | Not measured in the current experiments | Memory-overhead claim is not reproduced |

The most important deviation is the replacement of SPEC CPU2006 with a single GEMM workload. This limits the generality of the performance comparison.

The current experiments also cover only selected memory-error cases. They do not reproduce every detection capability or evaluation result discussed in the original paper.

## 5. Preliminary Claim Assessment

| Claim | Current Assessment | Evidence |
|---|---|---|
| ASan detects the tested heap use-after-free error | Supported for the recorded test | `heap-use-after-free` diagnostic in the experiment record |
| ASan detects the tested double-free error | Supported | Three raw logs report `attempting double-free` |
| ASan detects heap out-of-bounds in our experiment | Not yet established | No confirming raw log available |
| ASan detects the tested `malloc(0)` case | Not yet established | No confirming raw log available |
| ASan introduces runtime overhead | Supported | GEMM runtime increased from 1.301649 s to 2.367546 s on average |
| Our experiment reproduces the paper's exact 73% average slowdown | Not supported as an exact reproduction | Different benchmark workload and measured slowdown of approximately 81.9% |

These assessments refer only to the experiments currently documented by the group. They should be updated if additional verified evidence becomes available.

## 6. Remaining Work

Before final submission, the group should:

1. Obtain and preserve the raw logs for the three formal baseline runs and three formal ASan runs.
2. Confirm the standard-deviation calculation convention and correct the values in `workload.md`.
3. Verify the actual hardware, operating system, kernel, and compiler information in the environment documentation.
4. Obtain separate raw logs for heap out-of-bounds and `malloc(0)` if these tests remain part of the experimental plan.
5. Confirm the exact source files and compilation commands used for the memory-error tests.
6. Fix or document the external symbolizer path warning if readable source-level stack traces are required.
7. Avoid claiming memory-overhead reproduction unless the group conducts and documents the corresponding measurement.

## 7. Conclusion

The current experiments demonstrate that AddressSanitizer detected the recorded heap use-after-free error and successfully detected double-free in all three recorded boundary-test runs.

For the GEMM workload, the ASan-enabled build achieved a mean runtime of 2.367546 seconds, compared with 1.301649 seconds for the baseline build. This corresponds to an approximately 81.9% slowdown.

These results support the observation that AddressSanitizer can detect the tested memory errors and introduces runtime overhead. However, the reproduction remains limited in scope because it uses a single GEMM workload instead of the original SPEC CPU2006 benchmark suite and has not yet verified every planned memory-error test.

## Reference

Serebryany, K., Bruening, D., Potapenko, A., & Vyukov, D. (2012). *AddressSanitizer: A Fast Address Sanity Checker*. Proceedings of the USENIX Annual Technical Conference (USENIX ATC).
