# 1. Introduction and Claims

## 1.1 Introduction
Memory-safety errors, such as buffer overflows and use-after-free, remain a critical source of software defects and security vulnerabilities in C and C++ programs. AddressSanitizer (ASan), introduced by Serebryany et al. at USENIX ATC 2012, is a compiler-assisted memory error detector that addresses this challenge. By combining compiler instrumentation with a specialized runtime library, ASan checks memory accesses using shadow memory to detect errors at the point of occurrence. 

The original paper asserts that ASan provides comprehensive memory-error detection with practical performance overhead, reporting an average runtime slowdown of 73% and a 3.37x memory usage increase. The goal of our project is a reduced-scale reproduction of these core claims using a modern Clang/LLVM environment. In addition to evaluating these core claims, we conduct an extension experiment to investigate how heap redzone configuration affects ASan's performance overhead.

## 1.2 Claims under Assessment
Due to licensing constraints preventing the use of the original SPEC CPU2006 suite, we focus on reproducing two core claims using a self-contained GEMM workload as a substitute.

**Claim 1: Memory-Error Detection (Functionality)**
- **Claim Statement**: ASan can detect representative memory-safety errors, including out-of-bounds accesses (heap, stack, and global) and use-after-free bugs. (Reference: Paper Abstract, Section 3.1, and Figure 1).
- **Verification**: We compile 6 targeted C test cases with `-fsanitize=address` to verify detection. The diagnostic logs (e.g., `heap-buffer-overflow`, `stack-buffer-overflow`) are preserved in our repository (`logs/`), demonstrating ASan's ability to detect and report these errors at runtime.

**Claim 2: Runtime and Memory Overhead (Performance)**
- **Claim Statement**: Enabling ASan introduces a significant runtime slowdown (~73% in the paper) and memory overhead (~3.37x in the paper). (Reference: Paper Section 4, Figure 2, Table 1).
- **Verification**: We measure execution time and peak memory of our GEMM benchmark across 3 runs, reporting Mean ± Standard Deviation. 
  - **Baseline**: Compiled without ASan.
  - **ASan**: Compiled with `-fsanitize=address`.
  Both configurations use the identical GEMM workload and hardware conditions. The results are compared against the paper in a *Paper vs. Ours* table. All raw numbers are traceable to `logs/benchmark_result.md`.

## 1.3 Scope and Limitations
- **Reduced-Scale Reproduction**: We use a GEMM kernel (N=1000) instead of SPEC CPU2006. This limits the absolute comparability of our numerical results to the paper's suite-wide averages.
- **False Negatives**: As noted in the paper (Section 3.5), ASan can miss unaligned out-of-bounds accesses. We acknowledge this limitation but do not deliberately test these edge cases.
- **Unreproducible Claims**: The paper's historical claim of finding 300+ bugs in Chromium is treated as background information and is not experimentally reproduced.

## 1.4 Reference
Serebryany, K., Bruening, D., Potapenko, A., & Vyukov, D. (2012). AddressSanitizer: A Fast Address Sanity Checker. In *Proceedings of the 2012 USENIX Annual Technical Conference (USENIX ATC '12)* (pp. 309–318). USENIX Association.