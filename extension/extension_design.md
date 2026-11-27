# Extension Experiment: Multi-Threaded GEMM Scalability & Overhead Under ASan

## 1. Background
AddressSanitizer (Serebryany et al., USENIX ATC '12) uses compiler instrumentation and shadow memory to catch memory errors.
Its runtime library supports multi-threaded programs without global locks on every memory access (Section 3.3 and Section 3.7).
Our baseline replication evaluates ASan on single-threaded execution.

## 2. Motivation
Single-threaded runs do not show how ASan behaves when the same workload runs across multiple threads.
Just tuning a runtime parameter is not a mechanism-level change.
Extending the same GEMM workload to multiple threads on the same hardware tests concurrency scaling and overhead directly.

## 3. Problem
On the same hardware and with the same total GEMM workload,
how does scaling from single-threaded execution to multi-threaded execution (`pthreads`) affect ASan's runtime overhead,
parallel scaling, and peak memory footprint compared with non-ASan execution?

## 4. Solution
We keep the hardware, OS, compiler, `-O2` optimization level, and total GEMM computational work unchanged.
Following single-factor control, we vary concurrency across `1`, `2`, `4`, and `8` POSIX threads (`pthreads`) while keeping total matrix work invariant,
and compare Baseline (`-O2 -pthread`) against ASan (`-O2 -pthread -fsanitize=address`).

* **Workload**: Multi-threaded GEMM source under `experiments/workload/` (same total GEMM work partitioned across threads)
* **Execution Script**: `scripts/run_extension.sh` (outputs to `results/extension_result.md` and logs under `logs/extension/`)
* **Plotting Script**: `scripts/plot_extension.py` (generates plots under `figure/`)
* **Reported Metrics**: Summary outputs include `label`, `threads`, `min_s`, `mean_s`, `std_s`, `peak_mem_mb`, `memory_ratio`, `speedup`, and `slowdown`.

### Metric Definitions (Notes)
* **Speedup (`speedup`)**: Computed as `baseline mean_s / current mean_s`, using `serial` (`1.493021s`) as the reference for non-ASan runs and `serial_asan` (`2.624101s`) as the reference for ASan runs.
* **Slowdown (`slowdown`)**: Computed at the same thread count as `ASan mean_s / Baseline mean_s` (`1.76x` for `serial_asan` vs. `serial`, and `1.83x`, `2.13x`, `1.94x`, and `2.03x` for `pthread_asan` vs. `pthread` across `1`, `2`, `4`, and `8` threads).
* **Peak Memory & Ratio (`peak_mem_mb`, `memory_ratio`)**: `peak_mem_mb` reports peak process RSS in MB across runs; `memory_ratio` is `pthread_asan peak_mem_mb / pthread peak_mem_mb` at each thread count (`2.53` in the summary table across `1`, `2`, `4`, and `8` threads).
* **Missing Memory Values**: `serial` shows `NA` (and `serial_asan` in the summary table shows `0.00` without a separate `memory_ratio`) because peak memory was not recorded for serial runs.
* **Correctness Check**: Both 1-thread and 8-thread `pthread` runs produce the exact same checksum (`249500249.99999997`).

## 5. Results
For specific results (including `label`, `threads`, `min_s`, `mean_s`, `std_s`, `peak_mem_mb`, `memory_ratio`, `speedup`, and `slowdown`), please refer to `results/extension_result.md`.

## 6. Analysis

### Expected Results Analysis
* **Runtime & Slowdown (`min_s`, `mean_s`, `std_s`, `slowdown`)**: Inline shadow-memory checks avoid global locks on every memory access, so `slowdown` across `1`, `2`, `4`, and `8` threads should stay broadly consistent with single-threaded behavior while `min_s` and `mean_s` drop as threads scale, with `std_s` reflecting run-to-run variance.
* **Parallel Scaling (`speedup`)**: Both Baseline and ASan should show higher `speedup` from `1` to `2`, `4`, and `8` threads on the same GEMM work, though scaling may be bounded by memory bandwidth, cache sharing, or thread coordination.
* **Peak Memory & Memory Ratio (`peak_mem_mb`, `memory_ratio`)**: Peak memory (MB) should edge up slightly with more threads due to extra thread stacks and per-thread runtime state, while `memory_ratio` remains roughly stable because ASan's shadow memory and runtime footprint dominate overall memory usage.

### Actual Results Analysis
* **Runtime & Slowdown (`min_s`, `mean_s`, `std_s`, `slowdown`)**: Across all tested configurations, ASan increases runtime over non-ASan runs (`1.76x` for `serial_asan`, and `1.83x`, `2.13x`, `1.94x`, and `2.03x` for `pthread_asan` at `1`, `2`, `4`, and `8` threads).
* Mean runtime (`mean_s`) decreases steadily as threads scale up, from `1.482590s` (1T) to `0.484783s` (8T) for `pthread`, and from `2.717689s` (1T) to `0.982637s` (8T) for `pthread_asan`.
* Rather than staying strictly constant across thread counts, `slowdown` rises to `2.13x` at `2` threads, dips to `1.94x` at `4` threads, and reaches `2.03x` at `8` threads, with `std_s` staying low on most runs (`0.001140s` to `0.025472s`) and showing higher variance at `2` threads (`0.121650s` for `pthread`, `0.420357s` for `pthread_asan`).
* **Parallel Scaling (`speedup`)**: Both non-ASan and ASan runs scale faster as threads increase on the same total GEMM workload while keeping `checksum` bitwise identical (`249500249.99999997` across `1` and `8` threads).
* Relative to `serial` (`1.493021s`), `pthread` speedup reaches `1.01` (1T), `1.64` (2T), `2.56` (4T), and `3.08` (8T).
* Relative to `serial_asan` (`2.624101s`), `pthread_asan` speedup reaches `0.97` (1T), `1.35` (2T), `2.32` (4T), and `2.67` (8T), tracking native scaling closely while staying slightly behind at higher thread counts due to extra shadow-memory traffic and memory-bandwidth contention.
* **Peak Memory & Memory Ratio (`peak_mem_mb`, `memory_ratio`)**: Peak memory stays nearly flat as threads scale (`24.38 MB` to `24.45 MB` for `pthread`; `61.56 MB` to `61.75 MB` for `pthread_asan`), yielding a constant `memory_ratio` of `2.53` across `1`, `2`, `4`, and `8` threads.
* Connecting to the paper (Sections 3.3 and 3.7), ASan's shadow-memory mapping and baseline runtime structures drive the main memory overhead, while scaling up to `8` threads adds minimal per-thread peak RSS growth.
