# 1. Introduction and Claims

## 1.1 Introduction
Memory-safety bugs such as buffer overflows and use-after-free remain a major source of reliability and security issues in C and C++ software.
AddressSanitizer (ASan), introduced by Serebryany et al. at USENIX ATC '12, addresses this problem using compiler instrumentation and shadow memory to catch invalid memory accesses at runtime.

The original paper reports an average runtime slowdown of ~73% and a ~3.37x memory overhead across SPEC CPU2006.
In this project, we conduct a reduced-scale reproduction of ASan's core claims using a modern Clang/LLVM toolchain and a self-contained dense matrix-multiplication (`gemm`) workload, alongside a multi-threaded `pthreads` extension (`1`, `2`, `4`, and `8` threads) on the same hardware and core GEMM workload.

## 1.2 Claims Under Assessment
Because SPEC CPU2006 is commercial software and unavailable in our setup, we evaluate two core claims using targeted micro-tests and a deterministic `gemm` (`N=1000`) benchmark:

- **Claim 1: Memory-Error Detection (Functionality)**
  - **Claim Statement**: ASan detects core memory-safety bugs (such as heap, stack, and global out-of-bounds accesses, as well as use-after-free and double-free) at runtime while exhibiting well-defined false-negative boundaries (Paper Abstract, Section 3.1, Section 3.5, and Section 4.2).
  - **Verification**: We compile 5 targeted bug test cases (`experiments/bug_tests/`) and 3 false-negative test cases (`experiments/false_negative/`) at `-O0 -fsanitize=address -g`, preserving raw diagnostic outputs under `logs/`.

- **Claim 2: Runtime and Memory Overhead (Performance)**
  - **Claim Statement**: Enabling ASan introduces a noticeable runtime slowdown (~73% in the paper) and peak memory overhead (~3.37x in the paper) under `-O2` (Paper Section 4, Figure 2, and Table 1).
  - **Verification**: Using `experiments/workload/gemm.c` (`N=1000`) across 3 runs (reporting `mean ± std`, slowdown, and peak memory ratio), we compare `-O2` baseline against `-O2 -fsanitize=address` under both default ASan settings (`74.50%` slowdown, `2.51x` memory ratio) and the paper's evaluation parameters (`68.81%` slowdown, `2.51x` memory ratio), traceable to `results/benchmark_result.md`, `results/paper_params_result.md`, and `logs/`.

## 1.3 Scope and Limitations
- **Reduced-Scale Workload**: We substitute a `1000 × 1000` GEMM workload for SPEC CPU2006, which provides deterministic compute and memory traffic but does not cover the full diversity of real-world C/C++ workloads.
- **False-Negative Boundaries**: We empirically examine ASan's false-negative cases (such as unaligned accesses, out-of-bounds accesses beyond redzones, and quarantine exhaustion) rather than claiming exhaustive bug discovery across large codebases like Chromium.
- **Extension Scope**: Our extension (`extension/extension_design.md` and `results/extension_result.md`) evaluates `pthreads` concurrency (`1`, `2`, `4`, and `8` threads) on the same total GEMM workload, whereas the paper's Section 4 performance benchmarks are single-threaded.

## 1.4 Reference
Serebryany, K., Bruening, D., Potapenko, A., & Vyukov, D. (2012). AddressSanitizer: A Fast Address Sanity Checker. In *Proceedings of the 2012 USENIX Annual Technical Conference (USENIX ATC '12)* (pp. 309–318). USENIX Association.