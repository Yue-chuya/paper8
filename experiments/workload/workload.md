# Workload and Pilot Results

## Benchmark
- Self-contained `gemm.c` (Matrix Multiplication, N=1000)
- Reason: SPEC CPU2006 is unavailable; this serves as a reduced-scale compute-intensive substitute. We run it via the group's automated script.

## Commands
- Run script: `./scripts/run_benchmark.sh`
- baseline: `clang -O2 experiments/workload/gemm.c -o demo_baseline`
- asan: `clang -O2 -fsanitize=address experiments/workload/gemm.c -o demo_asan`

## Pilot Results
- Baseline runtime: 1.282892 s
- ASan runtime: 2.395257 s
- Calculated slowdown: 2.395257 / 1.282892 ≈ 1.87x (Paper reports ~1.73x)

## Logs
- baseline.log (latest automated run)
- asan.log (latest automated run)

11.9-11.15 update

## Final Results (3 Runs)

### Baseline (ASan OFF)
- Runs: 1.298579, 1.285835, 1.320533
- Mean: 1.3016 s
- Standard Deviation (Std): 0.0146 s

### ASan (ASan ON)
- Runs: 2.330606, 2.329792, 2.442241
- Mean: 2.3675 s
- Standard Deviation (Std): 0.0526 s

### Final Slowdown Comparison
- Calculated Slowdown: 2.3675 / 1.3016 ≈ **1.82x** 
- (Paper reports ~1.73x, confirming a highly consistent trend)

## --------------------NEW benchmark-------------------------------
## Final Results (Automated Script - 3 Runs)

### Environment
- **Hardware:** Apple Silicon (macOS)
- **Compiler:** Apple clang version 14.0.0 (clang-1400.0.29.202)

### Baseline (ASan OFF)
- Runs: 1.584134, 1.578419, 1.486961
- Mean: 1.5498 s
- Standard Deviation (Std): 0.0445 s
- Peak Memory: 24.38 MB

### ASan (ASan ON)
- Runs: 2.597861, 2.602678, 2.590914
- Mean: 2.5972 s
- Standard Deviation (Std): 0.0048 s
- Peak Memory: 61.44 MB

### Final Slowdown Comparison
- **Calculated Ratio:** 2.5972 / 1.5498 ≈ **1.68x**
- **Calculated Slowdown:** **67.58%**
- **Memory Ratio:** **2.52x**
- **Comparison with Paper:** The paper reports an average slowdown of ~73% (1.73x). Our measured result (67.58%) is highly consistent in trend and magnitude, within ~5 percentage points of the paper's average. The slight difference can be attributed to our different workload (GEMM vs. SPEC CPU2006) and modern compiler optimizations.
 - Memory: Paper ~3.37x, Ours 2.52x (Same magnitude, ASan significantly inflates memory).

## Logs
- The raw timings and statistics are automatically recorded in `logs/benchmark_result.md`.
