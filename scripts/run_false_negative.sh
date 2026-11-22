#!/bin/bash

cd "$(dirname "$0")/.."
EXP_DIR="experiments/false_negative"
LOG_DIR="logs"

mkdir -p "$LOG_DIR"
set +e

echo "=== Testing False Negatives under DEFAULT ASan Settings ==="

echo "Compiling test cases (-O0)..."
clang -O0 -fsanitize=address -g "$EXP_DIR/exp_far_oob.c" -o "$EXP_DIR/exp_far_oob"
clang -O0 -fsanitize=address -g "$EXP_DIR/exp_unaligned.c" -o "$EXP_DIR/exp_unaligned"
clang -O0 -fsanitize=address -g "$EXP_DIR/exp_uaf_quarantine.c" -o "$EXP_DIR/exp_uaf_quarantine"
echo ""

echo "--- [Test 1] Far OOB (200-byte overflow) ---"
echo "Running with DEFAULT ASan settings..."
"$EXP_DIR/exp_far_oob" > "$LOG_DIR/fn_far_oob.log" 2>&1
if [ $? -eq 0 ]; then 
    echo "False Negative achieved! (Program survived)" 
else 
    echo "Caught by ASan (Unexpected under default settings)" 
fi
echo ""

echo "--- [Test 2] Unaligned OOB (+6 bytes offset) ---"
echo "Running with DEFAULT ASan settings..."
"$EXP_DIR/exp_unaligned" > "$LOG_DIR/fn_unaligned.log" 2>&1
if [ $? -eq 0 ]; then 
    echo "False Negative achieved! (Program survived)" 
else 
    echo "Caught by ASan (Modern ASan is stricter than paper)" 
fi
echo ""

echo "--- [Test 3] UAF via Default Quarantine Drain ---"
echo "Running with DEFAULT ASan settings..."
"$EXP_DIR/exp_uaf_quarantine" > "$LOG_DIR/fn_uaf_quarantine.log" 2>&1
if [ $? -eq 0 ]; then 
    echo "False Negative achieved! (Program survived)" 
else 
    echo "Caught by ASan (Quarantine might be larger than 300MB in this env)" 
fi

echo "All False Negative tests completed under DEFAULT settings."
echo "Raw logs saved in $LOG_DIR/fn_*.log"
set -e