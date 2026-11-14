# Reproduction Guide: AddressSanitizer (ASan) Evaluation

This document provides a step-by-step guide to reproduce our experimental results for the paper *AddressSanitizer: A Fast Address Sanity Checker*.

## 1. Prerequisites

- **Operating System**: macOS (Apple Silicon) or Ubuntu (WSL2)
- **Compiler**: Clang (with ASan support)
- **Tools**: `bash`, `awk`, `make`

## 2. Quick Start

### Step 2.1: Clone the Repository
```bash
git clone https://github.com/Yue-chuya/paper8
cd paper8
```

### Step 2.2: Functional Tests (Bug Detection)
We provide 4 distinct test cases to validate ASan's detection capabilities.
Run the automated script:
```bash
chmod +x scripts/run_bug_tests.sh
./scripts/run_bug_tests.sh
```
**Expected Output**:
- The terminal will print `Bug detected in [test_name]!` for all 4 tests.
- Detailed ASan error reports (e.g., `heap-buffer-overflow`, `double-free`) will be saved in the `logs/` directory.

### Step 2.3: Performance Benchmark (Runtime Overhead)
Our benchmark uses a self-contained GEMM (N=1000) implementation. The script compiles both baseline and ASan versions, runs them 3 times, and calculates the mean and standard deviation.
```bash
chmod +x scripts/run_benchmark.sh
./scripts/run_benchmark.sh
```
**Expected Output**:
You should see a statistical summary in the terminal, for example:
```text
Baseline Mean: 1.5498 s, Std: 0.0445
ASan Mean: 2.5972 s, Std: 0.0048
Ratio: 1.68x
Slowdown: 67.58%
Memory Ratio: 2.52x

```
The raw timings and markdown-formatted results will be automatically saved as `logs/benchmark_result.md`.

### Step 2.4: Clean Up
To remove all compiled binaries and keep the repository clean:
```bash
bash scripts/clean.sh
```

## 3. Deviations and Engineering Choices
- **Benchmark Substitution**: We used a self-contained GEMM (N=1000) instead of SPEC CPU2006 due to licensing and environment constraints. This serves as a reduced-scale compute-intensive substitute.
- **Optimization Levels**: The performance benchmark uses `-O2` to align with the paper's evaluation settings. However, functional bug tests are compiled with `-O0` (and modified with `volatile`/dynamic control flow). This is because modern Clang optimizers aggressively eliminate undefined-behavior code (dead code elimination) at higher optimization levels, masking the bugs before ASan can intercept them.
- For a detailed analysis of deviations, please refer to [`docs/deviations.md`](docs/deviations.md).