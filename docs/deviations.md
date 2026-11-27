Experimental Deviations from the Original Paper
This document records the deviations between our reduced-scale reproduction and the original experimental evaluation in Serebryany et al., "AddressSanitizer: A Fast Address Sanity Checker" (USENIX ATC '12, Section 4).

1. Workload: Benchmark Suite
Original Setting: SPEC CPU2006 (20+ diverse C/C++ integer and floating-point programs).

Our Setting: Self-contained GEMM matrix multiplication experiments/workload/gemm.c (N=1000).

Reason: Licensing & Scope. SPEC CPU2006 requires a commercial license. GEMM serves as a deterministic, compute- and memory-access-intensive substitute for evaluating runtime and memory overhead.

2. Hardware: CPU & RAM
Original Setting: HP Z600 workstation (2x quad-core Intel Xeon E5620, 8 cores total, 24 GB RAM).

Our Setting: Apple Silicon (Apple M2, 8 GB RAM) and WSL2 (13th Gen Intel(R) / AMD Ryzen 5 4500U, 16 GB RAM).

Reason: Resource Constraint. Experiments were conducted on available local student hardware rather than a dedicated multi-socket lab workstation.

3. OS: Operating System
Original Setting: 64-bit bare-metal Linux.

Our Setting: macOS (Darwin 21.6.0) and Linux (Ubuntu 22.04 on WSL2).

Reason: Environment Constraint. Evaluation was performed across available personal OS environments; WSL2 introduces slight virtualization overhead in memory mapping and I/O.

4. Compiler: Compiler Toolchain
Original Setting: LLVM Clang (c. 2011–2012, LLVM 3.1+ era).

Our Setting: Apple Clang 14.0.0 (macOS) and Ubuntu Clang 21.1.8 (WSL2).

Reason: Modern Toolchain. Over a decade of compiler evolution introduces more aggressive loop optimizations, auto-vectorization, and updated ASan runtime passes, affecting both baseline execution time and ASan instrumentation overhead.

5. Compiler: Optimization Levels
Original Setting: -O2 for performance evaluation.

Our Setting: -O2 for performance benchmarks (-O2 -pthread for extension); -O0 -g for bug detection and false-negative tests.

Reason: Preventing Fault Elimination. Modern -O2 optimizers aggressively eliminate dead stores and undefined-behavior accesses (such as intentional out-of-bounds or use-after-free faults) prior to instrumentation. -O0 ensures injected bugs remain intact at runtime.

6. Config: ASan Runtime Parameters
Original Setting: quarantine_size_mb=0:redzone=32:malloc_context_size=0 for the main CPU2006 evaluation (Section 4), while defaults are quarantine=256MB, redzone=128B, unwind_depth=30 (Section 4.3).

Our Setting: Evaluated under both Default ASan settings and the Paper's exact evaluation parameters (ASAN_OPTIONS="quarantine_size_mb=0:redzone=32:malloc_context_size=0").

Reason: Rigorous Comparison. Matching the paper's exact parameters isolates pure instrumentation overhead for fair comparison, whereas default parameters reflect realistic deployment behavior.

7. Testing: Bug Detection Verification
Original Setting: Detected 3 bugs in SPEC CPU2006 (h264ref, perlbench) and 300+ previously unknown bugs in Chromium via unit tests and fuzzing (Section 4.2).

Our Setting: 5 isolated micro C programs (experiments/bug_tests/) covering Use-After-Free, Double-Free, Heap OOB, Stack OOB, and Global OOB.

Reason: Feasibility & Isolation. Building and fuzzing full-scale Chromium is infeasible within project constraints. Focused micro-benchmarks cleanly verify each core bug class claimed in Section 1 and Section 4.2.

8. Testing: False Negatives
Original Setting: Theoretically analyzed three limitations in Section 3.5: unaligned partially OOB accesses, far OOB accesses jumping over redzones, and quarantine queue exhaustion.

Our Setting: Empirically reproduced and verified all three theoretical false-negative scenarios via dedicated test cases (experiments/false_negative/).

Reason: Empirical Validation. Concretely demonstrates the boundary conditions where ASan fails to report memory errors, confirming Section 3.5 of the paper.

9. Extension: Multi-Threaded Scalability (pthreads)
Original Setting: Thread-safety design described in Section 3.7 (lock-free shadow reads, thread-local allocator caches), but Section 4 evaluated single-threaded SPEC CPU2006 workloads only.

Our Setting: Extended GEMM with pthreads across 1, 2, 4, and 8 threads (-O2 -pthread vs. -O2 -pthread -fsanitize=address) while keeping total computational work constant (extension/extension_design.md).

Reason: Mechanism-Level Extension. Evaluates how ASan's runtime overhead, parallel speedup, and peak memory footprint scale under multi-threaded concurrency on multi-core hardware.

10. Scope: Secondary Paper Evaluations
Original Setting: Also evaluated writes-only instrumentation (26% avg slowdown), alternative shadow Scale/Offset (-fPIE/-pie) settings, stack size increase (VmStk, Table 2), binary size increase (1.5x–3.2x), and comparisons against Valgrind, Dr. Memory, Mudflap, Duma, and DieHarder (Section 4.1).

Our Setting: Omitted / Out of Scope. Focused on read+write instrumentation runtime slowdown, peak memory ratio, bug detection, false negatives, and multi-threaded scaling.

Reason: Scope Limit. GEMM lacks deep recursive stack frames to meaningfully test stack growth, and cross-tool / binary-size / writes-only sweeps were outside the scope of this reduced reproduction.

11. Methodology: Execution & Statistical Reporting
Original Setting: Reported single-benchmark ratios and totals across SPEC CPU2006, collecting peak memory (VmPeak) and stack size (VmStk) from /proc/self/status.

Our Setting: Automated Makefile and shell/Python pipeline running 3 repeated trials per configuration, reporting min_s, mean_s, standard deviation, slowdown, speedup, and peak memory (MB) in results/ and figure/.

Reason: Reproducibility & Variance Control. Multiple runs with mean and standard deviation account for OS scheduling and background noise on shared personal machines, while automation ensures one-command reproducibility (make run).