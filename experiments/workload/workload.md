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
