# Workloads

## 1. Benchmark Selection

The original AddressSanitizer paper evaluated its performance using the commercial SPEC CPU2006 benchmark suite. Since SPEC CPU2006 requires a paid license and was unavailable for this course project, we adopted a self-contained Dense Matrix Multiplication (GEMM) benchmark as a reduced-scale alternative. This provides a controlled workload for evaluating the runtime and memory overhead introduced by AddressSanitizer (ASan).

## 2. Workload Details

- **Benchmark Used:** Dense Matrix Multiplication (GEMM).
- **Input Size:** Three matrices of dimensions `1000 × 1000` are used, with an algorithmic complexity of \(O(N^3)\).
- **Source and Acquisition:** The benchmark was implemented from scratch by our group in standard C. Its source code is maintained in our project repository at `experiments/workload/gemm.c`. No external benchmark suite or dataset is required.
- **Input Generation:** The input matrices are initialized directly in the source code using deterministic values. Matrix A is initialized according to its row indices, while matrix B is initialized according to its column indices. The result matrix C is initialized to zero before computation. No random number generation or external input files are involved.
- **Memory Requirements:** The workload allocates three `1000 × 1000` double-precision arrays, requiring approximately 24 MB of memory in total.
- **Workload Characteristics:** The benchmark performs repeated floating-point multiplication and addition operations, together with frequent matrix memory accesses. This provides a controlled computational workload for observing the runtime and memory overhead introduced by ASan's instrumentation and shadow-memory mechanism.
- **Timing Method:** Execution time is measured using `clock_gettime(CLOCK_MONOTONIC)`. The measurement covers the matrix multiplication phase only; matrix initialization is excluded.
- **Scale Rationale:** We selected `N=1000` to provide a sufficiently substantial workload while keeping resource consumption manageable in our WSL2 and macOS testing environments. The workload is designed to run for approximately 1.5 seconds per execution, helping reduce the relative influence of short-duration timing noise.