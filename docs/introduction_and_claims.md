
# Report Draft: Introduction and Claims

> **Status:** Initial draft for the Week 3 checkpoint. This is a selected-claim, reduced-scale reproduction, not a complete reproduction of every experiment in the original paper.

## 1. Introduction

Memory-safety errors remain an important source of software defects in programs written in C and C++. Examples include out-of-bounds memory accesses, such as buffer overflows, and accesses to memory after it has been freed. These errors can cause program crashes, incorrect results, and security vulnerabilities. Detecting them during software development is therefore important.

AddressSanitizer (ASan), introduced by Serebryany et al. at USENIX ATC 2012, is a compiler-assisted memory error detector designed to identify several classes of memory-safety bugs. The system combines compiler instrumentation with a runtime library. The instrumentation checks memory accesses using shadow memory, while the runtime library manages poisoned memory regions and supports the detection of errors such as heap, stack, and global out-of-bounds accesses and heap use-after-free.

The original paper argues that ASan can provide broad memory-error detection with practical performance overhead. It reports an average runtime slowdown of approximately 73% and memory usage of approximately 3.4 times the original usage in its evaluation. The paper also reports that ASan helped discover more than 300 previously unknown bugs in Chromium.

The goal of this project is to reproduce selected aspects of the original work using the available Clang/LLVM AddressSanitizer implementation. We focus on two questions: whether ASan can detect representative memory-safety errors, and how enabling ASan affects the execution time of a selected workload. For the runtime experiment, our group uses the GEMM matrix-multiplication benchmark from PolyBench/C 4.2.1 rather than the SPEC CPU2006 benchmark suite used in the original paper. This substitution is a limitation of our reproduction and will be considered when interpreting the results.

This project is a reduced-scale reproduction. It does not reimplement ASan, reproduce the full benchmark suite, or independently verify the paper's historical Chromium bug-finding result.

## 2. Claims and Research Questions

We select the following claims for experimental investigation.

### Claim 1: Memory-error detection

**Claim:** AddressSanitizer can detect representative memory-safety errors, including heap buffer overflows and heap use-after-free.

**Evidence to collect:**

- The source code for each intentional memory-error test.
- The exact compiler command and ASan flags.
- The program's output, error diagnostic, and exit status.
- The corresponding raw log committed to the repository.

**Assessment rule:** Mark this claim as *Supported* only when the relevant test produces an ASan diagnostic identifying the intended error. If only one of the two error types is demonstrated, describe the result as partial support and state which test succeeded.

### Claim 2: Runtime overhead

**Claim:** Enabling AddressSanitizer increases execution time compared with running the same workload without ASan.

**Evidence to collect:**

- The same PolyBench/C 4.2.1 GEMM source and input configuration for both builds.
- The baseline build using `-O2` without ASan.
- The ASan build using `-O2 -fsanitize=address`.
- At least three timing runs per configuration, with raw logs.
- Mean and standard deviation for each configuration.

**Assessment rule:** Compare the measured runtime of the baseline and ASan-enabled builds. The original paper reports an average slowdown of approximately 73% across SPEC CPU2006 benchmarks. Our GEMM measurement is a different and narrower workload, so numerical proximity to 73% should be described as consistency with the paper's reported result, not as a direct reproduction of the paper's benchmark-wide average.

## 3. Scope and Limitations

- We use the existing Clang/LLVM AddressSanitizer implementation.
- We test selected memory-error cases rather than every error class discussed in the paper.
- We use one PolyBench/C 4.2.1 GEMM workload instead of the original SPEC CPU2006 benchmark suite.
- Three timing runs have been completed for each configuration. The measured results are based on this limited number of runs.
- The current project data do not yet establish a reproduced memory-overhead result.
- The historical claim about bugs found in Chromium is background information, not a claim tested by our experiments.

## Reference

Serebryany, K., Bruening, D., Potapenko, A., & Vyukov, D. (2012). AddressSanitizer: A Fast Address Sanity Checker. In *Proceedings of the 2012 USENIX Annual Technical Conference (USENIX ATC '12)* (pp. 309–318). USENIX Association.

https://www.usenix.org/conference/atc12/technical-sessions/presentation/serebryany
