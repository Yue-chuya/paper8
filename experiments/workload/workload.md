# Workload and Pilot Results (B-line)

## Benchmark
- PolyBench/C 4.2.1 (gemm)
- Reason: SPEC CPU2006 is unavailable; gemm serves as a reduced-scale compute-intensive substitute.

## Commands
- baseline: `clang -O2 -I utilities -I linear-algebra/blas/gemm utilities/polybench.c linear-algebra/blas/gemm/gemm.c -DPOLYBENCH_TIME -lm -o gemm_baseline`
- asan: same as baseline + `-fsanitize=address`

## Pilot Results
- Baseline runtime: 1.180874
- ASan runtime: 1.998864
- Calculated slowdown: 1.69x (Paper reports ~1.73x)

## Logs
- baseline.log
- asan.log
