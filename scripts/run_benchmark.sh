#!/bin/bash
set -e

cd "$(dirname "$0")/.."
WORK_DIR="experiments/workload"
SRC_FILE="$WORK_DIR/gemm.c"
LOG_DIR="logs"
RESULT_DIR="results"
RUNS=3
mkdir -p "$WORK_DIR" "$LOG_DIR" "$RESULT_DIR"

OS_TYPE=$(uname)
if [ "$OS_TYPE" == "Darwin" ]; then
    TIME_CMD="/usr/bin/time -l"
    MEM_GREP="maximum resident set size"
    MEM_AWK="{print \$1}" 
else
    TIME_CMD="/usr/bin/time -v"
    MEM_GREP="Maximum resident set size"
    MEM_AWK="{print \$NF}" 
fi

echo "----- Compiling Baseline (ASan OFF) -----"
clang -O2 "$SRC_FILE" -o "$WORK_DIR/demo_baseline"

echo "----- Running Baseline ($RUNS times) -----"
BASELINE_TIMES=()
BASELINE_MEM=()
for i in $(seq 1 $RUNS); do
    OUTPUT=$($TIME_CMD "$WORK_DIR/demo_baseline" 2>&1)
    TIME_VAL=$(echo "$OUTPUT" | head -n 1)
    BASELINE_TIMES+=($TIME_VAL)

    MEM_RAW=$(echo "$OUTPUT" | grep -i "$MEM_GREP" | awk "$MEM_AWK")
    if [ "$OS_TYPE" == "Darwin" ]; then
        MEM_VAL=$(awk "BEGIN {printf \"%.2f\", $MEM_RAW / 1048576}")
    else
        MEM_VAL=$(awk "BEGIN {printf \"%.2f\", $MEM_RAW / 1024}")
    fi
    BASELINE_MEM+=($MEM_VAL)
    
    echo "Run $i: Time = $TIME_VAL s, Peak Mem = $MEM_VAL MB"
done

echo "-----------------------------------------------------"
echo "----- Compiling with AddressSanitizer (ASan ON) -----"
clang -O2 -fsanitize=address "$SRC_FILE" -o "$WORK_DIR/demo_asan"

echo "----- Running ASan ($RUNS times) -----"
ASAN_TIMES=()
ASAN_MEM=()
for i in $(seq 1 $RUNS); do
    OUTPUT=$($TIME_CMD "$WORK_DIR/demo_asan" 2>&1)
    TIME_VAL=$(echo "$OUTPUT" | head -n 1)
    ASAN_TIMES+=($TIME_VAL)

    MEM_RAW=$(echo "$OUTPUT" | grep -i "$MEM_GREP" | awk "$MEM_AWK")
    if [ "$OS_TYPE" == "Darwin" ]; then
        MEM_VAL=$(awk "BEGIN {printf \"%.2f\", $MEM_RAW / 1048576}")
    else
        MEM_VAL=$(awk "BEGIN {printf \"%.2f\", $MEM_RAW / 1024}")
    fi
    ASAN_MEM+=($MEM_VAL)
    
    echo "Run $i: Time = $TIME_VAL s, Peak Mem = $MEM_VAL MB"
done

echo "-----------------------------------------------------"
echo "----- Calculating Statistics -----"
B_STR="${BASELINE_TIMES[*]}"
A_STR="${ASAN_TIMES[*]}"
BM_STR="${BASELINE_MEM[*]}" 
AM_STR="${ASAN_MEM[*]}" 

STATS=$(echo "$B_STR $A_STR $BM_STR $AM_STR" | awk -v n="$RUNS" '{
    # mean and std for Baseline
    b_sum = 0;
    for(i=1; i<=n; i++) { b_sum += $i; b_arr[i] = $i }
    b_mean = b_sum / n;
    b_var_sum = 0;
    for(i=1; i<=n; i++) { b_var_sum += ($i - b_mean)^2 }
    b_std = sqrt(b_var_sum / n);

    # mean and std for ASan
    a_sum = 0;
    for(i=n+1; i<=2*n; i++) { a_sum += $i; a_arr[i-n] = $i }
    a_mean = a_sum / n;
    a_var_sum = 0;
    for(i=n+1; i<=2*n; i++) { a_var_sum += ($i - a_mean)^2 }
    a_std = sqrt(a_var_sum / n);

    # mean for Peak Mem
    bm_sum = 0;
    for(i=2*n+1; i<=3*n; i++) { bm_sum += $i }
    bm_mean = bm_sum / n;

    am_sum = 0;
    for(i=3*n+1; i<=4*n; i++) { am_sum += $i }
    am_mean = am_sum / n;

    # Ratios
    time_ratio = a_mean / b_mean;
    slowdown = (time_ratio - 1) * 100;
    mem_ratio = am_mean / bm_mean;

    printf "- Baseline Mean: %.4f s, Std: %.4f\n", b_mean, b_std;
    printf "- ASan Mean: %.4f s, Std: %.4f\n", a_mean, a_std;
    printf "- Ratio: %.2fx\n", time_ratio;
    printf "- Slowdown: %.2f%%\n", slowdown;
    printf "- Baseline Peak Mem Mean: %.2f MB\n", bm_mean;
    printf "- ASan Peak Mem Mean: %.2f MB\n", am_mean;
    printf "- Memory Ratio: %.2fx\n", mem_ratio;
}')

echo "$STATS"
RESULT_FILE="$RESULT_DIR/benchmark_result.md"

cat << EOF > "$RESULT_FILE"
# Benchmark Result

## Raw Data
- Baseline:               ${B_STR}
- ASan:                   ${A_STR}
- Baseline Peak Mem (MB): ${BM_STR}
- ASan Peak Mem (MB):     ${AM_STR}

## Statistics
$STATS
EOF

echo "----------------------------------------"
echo "Benchmark completed."