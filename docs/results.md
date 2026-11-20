# Experimental Results

## 1. Experimental Configuration

### 1.1 Benchmark Selection

The original AddressSanitizer (ASan) paper used the SPEC CPU2006 benchmark suite to evaluate performance overhead.

However, SPEC CPU2006 was unavailable due to licensing and access constraints. Therefore, we used a self-contained matrix multiplication benchmark (`gemm.c`) as a substitute.

The benchmark uses a matrix size of N=1000. It provides a compute-intensive workload for comparing execution time and memory usage with and without ASan.

### 1.2 Compilation Commands

**Baseline (ASan OFF):**

```bash
clang -O2 experiments/workload/gemm.c -o demo_baseline
```

**ASan (ASan ON):**

```bash
clang -O2 -fsanitize=address experiments/workload/gemm.c -o demo_asan
```

### 1.3 Experimental Environment

| Item | Configuration |
|---|---|
| Operating System | macOS |
| Hardware Architecture | Apple Silicon |
| Compiler | Apple clang 14.0.0 |
| Benchmark | GEMM (Matrix Multiplication) |
| Matrix Size | N = 1000 |
| Number of Runs | 3 |

The benchmark was executed using the automated script:

```bash
./scripts/run_benchmark.sh
```

Raw results and statistics are recorded in:

`logs/benchmark_result.md`

---

## 2. Runtime Performance Results

We conducted three independent runs for both the baseline program and the ASan-instrumented program.

### 2.1 Raw Runtime Data

| Run | Baseline (seconds) | ASan (seconds) |
|---|---:|---:|
| Run 1 | 1.584134 | 2.597861 |
| Run 2 | 1.578419 | 2.602678 |
| Run 3 | 1.486961 | 2.590914 |
| **Mean** | **1.5498** | **2.5972** |
| **Standard Deviation** | **0.0445** | **0.0048** |

*Note: Standard deviations are reported using the population standard deviation convention, consistent with the recorded workload results.*

### 2.2 Performance Overhead

The slowdown ratio is calculated as:

\[
\text{Slowdown} =
\frac{\text{ASan Mean Runtime}}
{\text{Baseline Mean Runtime}}
\]

\[
= \frac{2.5972}{1.5498}
\approx 1.68
\]

The percentage slowdown is:

\[
(1.68-1)\times 100\% \approx 67.58\%
\]

Therefore, ASan increased the average execution time by approximately **67.58%**, corresponding to a slowdown of approximately **1.68×**.

---

## 3. Memory Usage Results

We also compared peak memory usage between the baseline and ASan-instrumented programs.

| Configuration | Peak Memory |
|---|---:|
| Baseline (ASan OFF) | 24.38 MB |
| ASan (ASan ON) | 61.44 MB |

The memory overhead ratio is calculated as:

\[
\text{Memory Overhead} =
\frac{\text{ASan Peak Memory}}
{\text{Baseline Peak Memory}}
\]

\[
= \frac{61.44}{24.38}
\approx 2.52
\]

Thus, the ASan-instrumented program used approximately **2.52×** the peak memory of the baseline program.

---

## 4. Comparison with the Original Paper

The following table compares our experimental results with the results reported in the original paper.

| Metric | Original Paper | Our Reproduction |
|---|---:|---:|
| Runtime Slowdown | Approximately 73% (1.73×) | 67.58% (1.68×) |
| Memory Overhead | Approximately 3.37× | 2.52× |
| Benchmark | SPEC CPU2006 | GEMM (N=1000) |

### 4.1 Runtime Comparison

Our experiment measured a runtime slowdown of approximately 67.58%, which is slightly lower than the approximately 73% reported in the original paper.

The difference is approximately 5.42 percentage points.

This difference may be related to the use of a smaller GEMM benchmark instead of the SPEC CPU2006 benchmark suite, as well as differences in hardware and compiler environments.

### 4.2 Memory Usage Comparison

Our measured memory overhead was approximately 2.52×, lower than the approximately 3.37× reported in the original paper.

One possible explanation is that our GEMM benchmark has a smaller memory footprint than the larger SPEC CPU2006 workloads.

---

## 5. Memory Error Detection Results

In addition to performance measurements, we tested ASan's ability to detect memory errors.

### 5.1 Heap Use-After-Free

The heap-use-after-free experiment successfully triggered an ASan error.

The output included:

```text
ERROR: AddressSanitizer: heap-use-after-free
READ of size 4
```

This demonstrates that ASan can detect an attempt to access heap memory after it has been freed.

### 5.2 Double-Free

We conducted three runs of the double-free experiment.

| Log File | Detection Result |
|---|---|
| boundary_run1.log | Detected |
| boundary_run2.log | Detected |
| boundary_run3.log | Detected |

All three runs reported:

```text
ERROR: AddressSanitizer: attempting double-free
SUMMARY: AddressSanitizer: double-free
ABORTING
```

The detection rate was:

\[
\frac{3}{3}\times 100\% = 100\%
\]

This confirms that ASan successfully detected the double-free error in all three recorded runs.

---

## 6. Analysis of Results

Our experiments provide evidence supporting the main performance and memory-error-detection characteristics of AddressSanitizer.

First, the performance experiment shows that ASan introduces measurable runtime overhead. Our measured slowdown was approximately 67.58%, which is reasonably close to the approximately 73% reported in the original paper.

Second, the memory experiment shows that ASan increases peak memory usage. Our measured memory overhead was approximately 2.52×, compared with approximately 3.37× in the original paper.

Third, the memory error experiments demonstrate that ASan can detect heap-use-after-free and double-free errors. In particular, the double-free experiment successfully detected the error in all three recorded runs.

Overall, the experimental results support the main characteristics described in the original paper, although the exact overhead values differ.

---

## 7. Deviations and Limitations

There are several differences between our reproduction and the original paper.

| Aspect | Original Paper | Our Reproduction |
|---|---|---|
| Benchmark Suite | SPEC CPU2006 | Self-contained GEMM benchmark |
| Benchmark Scale | Multiple benchmark programs | Single GEMM workload with N=1000 |
| Runtime Evaluation | SPEC CPU2006 performance evaluation | Three runs of GEMM |
| Experimental Environment | Original paper's experimental environment | macOS on Apple Silicon with Apple clang 14.0.0 |

The main deviation is the replacement of SPEC CPU2006 with a self-contained GEMM benchmark due to licensing and access constraints.

This limits the direct comparability of our performance results with those of the original paper. The results should therefore be interpreted as a reproduction of ASan's general performance characteristics rather than an exact replication of the original benchmark results.

---

## 8. Conclusion

Our reproduction experiments demonstrate that AddressSanitizer introduces measurable runtime and memory overhead while successfully detecting memory errors.

The GEMM benchmark showed a runtime slowdown of approximately 67.58% and a peak memory overhead of approximately 2.52×.

The memory error experiments also confirmed that ASan successfully detected heap-use-after-free and double-free errors.

Although our experimental setup differs from the original paper because we used GEMM instead of SPEC CPU2006, the results are broadly consistent with the performance characteristics reported by the original authors.

Therefore, our experiments provide supporting evidence for the main claims of the AddressSanitizer paper.

---

## 9. Items to Confirm Before Final Submission

- Confirm that the final GEMM benchmark results were produced on the stated Apple Silicon macOS environment.
- Ensure that `logs/benchmark_result.md` contains the same three runtime measurements and peak memory values reported above.
- Confirm that all referenced memory-error logs are included in the repository.
- Keep the benchmark substitution clearly documented as a deviation from the original paper.
