# Analysis of Discrepancies

## 1. Claim Verdicts
Based on our reduced-scale reproduction, we evaluate the two core claims of the original paper as follows:

- **Claim 1: Memory-Error Detection (Functionality) — SUPPORTED**
  - **Justification**: We tested 5 targeted memory-error scenarios (Heap OOB, Stack OOB, Global OOB, Use-After-Free, and Double-Free) compiled at `-O0` and observed 100% detection at runtime[cite: 11]. We also empirically reproduced the theoretical false-negative cases discussed in Section 3.5 (unaligned access, far out-of-bounds beyond redzones, and quarantine exhaustion), confirming the practical boundaries of ASan's detection mechanism[cite: 5, 11].
- **Claim 2: Runtime and Memory Overhead (Performance) — SUPPORTED**
  - **Justification**: Under the paper's evaluation settings (`quarantine_size_mb=0:redzone=32:malloc_context_size=0`), we measured a **68.81% slowdown** (**1.69x** runtime ratio), closely matching the paper's reported ~73% average slowdown (**1.73x**)[cite: 7, 14, 16]; under default ASan settings (`run_benchmark.sh`), we measured a **74.50% slowdown** (**1.75x** runtime ratio)[cite: 13, 15]. Across both configurations, the peak memory ratio is **2.51x**, supporting the paper's finding of substantial memory overhead (3.37x average across SPEC CPU2006)[cite: 7, 13, 14].

## 2. Gaps: Absolute and Relative Differences
While our findings support the paper's core claims, quantitative differences exist due to workload, compiler, runtime configuration, and environment differences[cite: 7, 11, 13, 14]:

- **Runtime Slowdown Gap**:
  - **Paper Params (`68.81%` / `1.69x`) vs. Paper (`73%` / `1.73x`)**: Absolute difference of **-4.19 percentage points** (`-0.04x` on the runtime ratio), or **-5.7%** relative to the `73%` slowdown figure (`-2.3%` relative on the `1.73x` runtime ratio)[cite: 7, 14, 16].
  - **Default Benchmark (`74.50%` / `1.75x`) vs. Paper (`73%` / `1.73x`)**: Absolute difference of **+1.50 percentage points** (`+0.02x` on the runtime ratio), or **+2.1%** relative to the `73%` slowdown figure (`+1.2%` relative on the `1.73x` runtime ratio)[cite: 7, 13, 15].
- **Memory Overhead Gap**:
  - Both Paper Params (**2.51x**, `60.99 MB / 24.33 MB`) and Default Benchmark (**2.51x**, `61.10 MB / 24.35 MB`) yield a **2.51x** peak memory ratio versus the paper's **3.37x** average across SPEC CPU2006, giving an absolute gap of **-0.86x** and a relative difference of **-25.5%**[cite: 7, 13, 14].

## 3. Evidence: Controlled Re-runs Explaining the Gaps
We conducted controlled checks and comparisons across configurations to separate toolchain, configuration, and workload effects from methodology issues[cite: 11, 13, 14]:

- **Evidence for Runtime Gap (Compiler Optimization & Runtime Configuration Effects)**: The original paper evaluated an earlier LLVM/Clang toolchain, whereas modern Clang (`-O2`) applies more aggressive loop/vectorization and scalar optimizations that reshape instrumented memory operations relative to baseline[cite: 7, 11]. In a controlled check with optimizations disabled (`-O0`), the slowdown measured **73.14%**, closely matching the paper's **73%**, supporting that modern `-O2` optimizations account for the ~4.19 percentage-point difference under paper parameters[cite: 7, 11, 14]. Additionally, Default Benchmark (`74.50%`) is slightly slower than Paper Params (`68.81%`) because default runtime settings do not disable stack unwinding or quarantine management (`quarantine_size_mb=0:redzone=32:malloc_context_size=0`)[cite: 8, 13, 14, 15, 16].
- **Evidence for Memory Gap (Workload Allocation Profile Effect)**: In the paper, memory overhead is driven primarily by allocator redzones (and quarantine when enabled) across diverse C/C++ applications in SPEC CPU2006 (averaging 3.37x across 19 reported benchmarks)[cite: 7, 8]. Our reproduction uses a compact `gemm.c` workload (~24.3 MB baseline peak RSS) with minimal dynamic heap allocation churn, resulting in a lower overall memory inflation ratio (**2.51x**) than the multi-benchmark SPEC CPU2006 average[cite: 7, 11, 13, 14].

## 4. Limitations: What This Reproduction Cannot Demonstrate
As a reduced-scale reproduction, this study has several explicit boundaries[cite: 11]:

- **Benchmark Suite Coverage**: A GEMM kernel cannot represent the full diversity of control flow, data structures, heap churn, and memory access patterns in the 20+ SPEC CPU2006 programs[cite: 7, 11].
- **Large-Scale Real-World Bug Discovery**: We cannot replicate testing a massive codebase like Chromium over 10 months (300+ bugs found); instead, we verify behavior using targeted micro-benchmarks and controlled false-negative tests[cite: 8, 11].
- **Unreproduced Paper Measurements**: We did not measure binary size expansion (reported as 1.5x–3.2x, average 2.5x), stack usage (`VmStk`) across diverse recursion depths, `writes-only` instrumentation (26% slowdown), or `Scale`/`Offset` tuning experiments[cite: 7].
- **Multi-Threaded Comparison Baseline**: The original paper's Section 4 performance evaluation is single-threaded[cite: 7, 12]. While our extension evaluates `pthreads` concurrency (`1`, `2`, `4`, and `8` threads) on GEMM, there is no multi-threaded baseline in the paper for direct quantitative comparison[cite: 7, 12].