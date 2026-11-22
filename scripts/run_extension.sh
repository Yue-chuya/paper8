#!/bin/bash
set -e

cd "$(dirname "$0")/.."
WORK_DIR="experiments/workload"
SRC_FILE="$WORK_DIR/malloc.c"
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

# Compiling Baseline and ASan
clang -O2 "$SRC_FILE" -o "$WORK_DIR/demo_baseline"
clang -O2 -fsanitize=address "$SRC_FILE" -o "$WORK_DIR/demo_asan"

# Running Baseline
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
done

# Running ASan with redzone=128
ASAN_128_TIMES=()
ASAN_128_MEM=()
for i in $(seq 1 $RUNS); do
    OUTPUT=$(ASAN_OPTIONS=redzone=128 $TIME_CMD "$WORK_DIR/demo_asan" 2>&1)
    TIME_VAL=$(echo "$OUTPUT" | head -n 1)
    ASAN_128_TIMES+=($TIME_VAL)
    MEM_RAW=$(echo "$OUTPUT" | grep -i "$MEM_GREP" | awk "$MEM_AWK")
    if [ "$OS_TYPE" == "Darwin" ]; then
        MEM_VAL=$(awk "BEGIN {printf \"%.2f\", $MEM_RAW / 1048576}")
    else
        MEM_VAL=$(awk "BEGIN {printf \"%.2f\", $MEM_RAW / 1024}")
    fi
    ASAN_128_MEM+=($MEM_VAL)
done

# Running ASan with redzone=32
ASAN_32_TIMES=()
ASAN_32_MEM=()
for i in $(seq 1 $RUNS); do
    OUTPUT=$(ASAN_OPTIONS=redzone=32 $TIME_CMD "$WORK_DIR/demo_asan" 2>&1)
    TIME_VAL=$(echo "$OUTPUT" | head -n 1)
    ASAN_32_TIMES+=($TIME_VAL)
    MEM_RAW=$(echo "$OUTPUT" | grep -i "$MEM_GREP" | awk "$MEM_AWK")
    if [ "$OS_TYPE" == "Darwin" ]; then
        MEM_VAL=$(awk "BEGIN {printf \"%.2f\", $MEM_RAW / 1048576}")
    else
        MEM_VAL=$(awk "BEGIN {printf \"%.2f\", $MEM_RAW / 1024}")
    fi
    ASAN_32_MEM+=($MEM_VAL)
done

# Calculating Statistics 
B_STR="${BASELINE_TIMES[*]}"
A128_STR="${ASAN_128_TIMES[*]}"
A32_STR="${ASAN_32_TIMES[*]}"
BM_STR="${BASELINE_MEM[*]}"
AM128_STR="${ASAN_128_MEM[*]}"
AM32_STR="${ASAN_32_MEM[*]}"

STATS=$(echo "$B_STR $A128_STR $A32_STR $BM_STR $AM128_STR $AM32_STR" | awk -v n="$RUNS" '{
    # Baseline
    b_sum = 0; for(i=1; i<=n; i++) { b_sum += $i; }
    b_mean = b_sum / n;
    bm_sum = 0; for(i=3*n+1; i<=4*n; i++) { bm_sum += $i; }
    bm_mean = bm_sum / n;

    # ASan 128B
    a128_sum = 0; for(i=n+1; i<=2*n; i++) { a128_sum += $i; }
    a128_mean = a128_sum / n;
    am128_sum = 0; for(i=4*n+1; i<=5*n; i++) { am128_sum += $i; }
    am128_mean = am128_sum / n;

    # ASan 32B
    a32_sum = 0; for(i=2*n+1; i<=3*n; i++) { a32_sum += $i; }
    a32_mean = a32_sum / n;
    am32_sum = 0; for(i=5*n+1; i<=6*n; i++) { am32_sum += $i; }
    am32_mean = am32_sum / n;

    # ratios and slowdowns
    ratio_128 = a128_mean / b_mean;
    slowdown_128 = (ratio_128 - 1) * 100;
    mem_ratio_128 = am128_mean / bm_mean;

    ratio_32 = a32_mean / b_mean;
    slowdown_32 = (ratio_32 - 1) * 100;
    mem_ratio_32 = am32_mean / bm_mean;

    printf "- **128B Redzone**\n";
    printf "  - Slowdown: **%.2f%%** (%.2fx)\n", slowdown_128, ratio_128;
    printf "  - Memory Ratio: **%.2fx**\n\n", mem_ratio_128;
    
    printf "- **32B Redzone**\n";
    printf "  - Slowdown: **%.2f%%** (%.2fx)\n", slowdown_32, ratio_32;
    printf "  - Memory Ratio: **%.2fx**\n", mem_ratio_32;
}')

echo "$STATS"

RESULT_FILE="$RESULT_DIR/extension_result.md"
cat << EOF > "$RESULT_FILE"
# Extension Experiment Result
**Single Modified Factor:** Redzone Size (128B vs 32B)

## Raw Data
- Baseline Times:      ${B_STR}
- ASan(128B) Times:    ${A128_STR}
- ASan(32B) Times:     ${A32_STR}
- Baseline Peak Mem:   ${BM_STR}
- ASan(128B) Peak Mem: ${AM128_STR}
- ASan(32B) Peak Mem:  ${AM32_STR}

## Statistics & Comparison
$STATS
EOF
echo "----------------------------------------"
echo "Extension Benchmark completed."