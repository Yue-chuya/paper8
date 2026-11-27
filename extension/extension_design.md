# Extension Experiment: Multi-Threaded GEMM Scalability & Overhead Under ASan

## 1. Background
AddressSanitizer (Serebryany et al., USENIX ATC '12) uses compiler instrumentation and shadow memory to catch memory errors. AddressSanitizer is thread-safe and it supports multi-threaded programs without global locks on every memory access [Section 3.7]. Our baseline replication evaluates ASan on single-threaded execution.

## 2. Motivation
Single-threaded runs do not show how ASan behaves when the same workload runs across multiple threads. Extending the same GEMM workload to multiple threads on the same hardware can test the performance scaling capability and runtime overhead under concurrency directly.

## 3. Problem
On the same hardware and with the same total GEMM workload, how does scaling from single-threaded execution to multi-threaded execution (`pthreads`) affect ASan's runtime overhead, parallel scaling, and peak memory footprint compared with non-ASan execution?

## 4. Solution
We keep the hardware, OS, compiler, `-O2` optimization level, and total GEMM computational work unchanged. Following single-factor control, we vary concurrency across `1`, `2`, `4`, and `8` POSIX threads (`pthreads`) while keeping total matrix work invariant, and compare Baseline (`-O2 -pthread`) against ASan (`-O2 -pthread -fsanitize=address -fno-omit-frame-pointer`).

- **Workload**: Multi-threaded GEMM source `experiments/workload/gemm_thread.c` (same total GEMM work partitioned across threads).
- **Execution Script**: `scripts/run_extension.sh` (outputs to `results/extension_result.md`)
- **Plotting Script**: `scripts/plot_extension.py` (generates plots under `figure/extension/`)
- **Reported Metrics**: Summary outputs include `label`, `threads`, `min_s`, `mean_s`, `std_s`, `peak_mem_mb`, `memory_ratio`, `speedup`, and `slowdown`.

### Metric Definitions
- **Speedup (`speedup`)**: 
    - `speedup = baseline mean_s / current mean_s`
    - Using `serial` as the reference for non-ASan runs and `serial_asan` as the reference for ASan runs.
- **Slowdown (`slowdown`)**: 
    -  `slowdown = ASan mean_s / Baseline mean_s` at same thread count (`serial_asan` vs. `serial`, and `pthread_asan` vs. `pthread`).
- **Peak Memory & Ratio (`peak_mem_mb`, `memory_ratio`)**:
    - `peak_mem_mb` reports peak process RSS in MB across runs
    - `memory_ratio = pthread_asan peak_mem_mb / pthread peak_mem_mb` at each thread count.
- **Missing Memory Values**: 
    - `serial` shows `NA`, and `serial_asan` in the summary table shows `0.00` without a separate `memory_ratio` because peak memory was not recorded for serial runs.
- **Correctness Check**:
    - Both 1-thread and 8-thread `pthread` runs produce the exact same checksum.

## 5. Results
For specific results please refer to `results/extension_result.md`.

## 6. Analysis

### Expected Results
- **Runtime (`min_s`, `mean_s`, `std_s`)**: 
`min_s`, `mean_s` and `std_s` **drop** as threads scale, with `std_s` reflecting run-to-run variance.

- **Slowdown (`slowdown`)**:
Inline shadow-memory checks avoid global locks on every memory access, so `slowdown` across `1`, `2`, `4`, and `8` threads should stay broadly consistent with single-threaded behavior and show an **increasing** trend.

- **Parallel Scaling (`speedup`)**:
Both Baseline and ASan should show **higher** `speedup` from `1` to `2`, `4`, and `8` threads on the same GEMM work, though scaling may be bounded by memory bandwidth, cache sharing, or thread coordination.

- **Peak Memory & Memory Ratio (`peak_mem_mb`, `memory_ratio`)**: 
Peak memory (MB) should edge **up slightly** with more threads due to extra thread stacks and per-thread runtime state, while `memory_ratio` **remains roughly stable** because ASan's shadow memory and runtime footprint dominate overall memory usage.

### Actual Results
- **Runtime (`min_s`, `mean_s`, `std_s`)**: 
`min_s` and `mean_s` decrease steadily as threads scale up **(meeting expectation)**, while `std_s` shows some run-to-run fluctuation rather than dropping monotonically.

- **Slowdown (`slowdown`)**:
Rather than staying strictly constant across thread counts, `slowdown` fluctuates across 1, 2, 4, and 8 threads.

- **Parallel Scaling (`speedup`)**: 
Both non-ASan and ASan runs scale faster as threads increase on the same total GEMM workload while keeping `checksum` bitwise identical.  **(meeting expectation)**

- **Peak Memory & Memory Ratio (`peak_mem_mb`, `memory_ratio`)**:
Peak memory stays nearly flat as threads scale (`pthread`: around 24 MB; `pthread_asan`: around 61 MB), yielding a constant `memory_ratio` of `2.53` across `1`, `2`, `4`, and `8` threads.

