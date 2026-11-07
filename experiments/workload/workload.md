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