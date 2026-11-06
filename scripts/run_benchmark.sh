#!/bin/bash
set -e

WORK_DIR="experiments/workload"
SRC_FILE="$WORK_DIR/gemm.c"

mkdir -p "$WORK_DIR"

echo "=== [1/4] Compiling Baseline (ASan OFF) ==="
clang -O2 "$SRC_FILE" -o "$WORK_DIR/demo_baseline"

echo "=== [2/4] Running Baseline and saving to baseline.log ==="
time "$WORK_DIR/demo_baseline" | tee "$WORK_DIR/baseline.log" || true

echo "=== [3/4] Compiling with AddressSanitizer (ASan ON) ==="
clang -O2 -fsanitize=address "$SRC_FILE" -o "$WORK_DIR/demo_asan"

echo "=== [4/4] Running with ASan and saving to asan.log ==="
time "$WORK_DIR/demo_asan" | tee "$WORK_DIR/asan.log" || true

echo "=== Benchmark script completed successfully! Logs updated in $WORK_DIR/ ==="