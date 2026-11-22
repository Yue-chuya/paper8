#!/bin/bash

cd "$(dirname "$0")/.."
EXP_DIR="experiments/false_negative"
LOG_DIR="logs/false_negative"
mkdir -p "$LOG_DIR"
set +e

echo "Testing False Negatives (-O0)"
clang -O0 -fsanitize=address -g "$EXP_DIR/exp_far_oob.c" -o "$EXP_DIR/exp_far_oob"
clang -O0 -fsanitize=address -g "$EXP_DIR/exp_unaligned.c" -o "$EXP_DIR/exp_unaligned"
clang -O0 -fsanitize=address -g "$EXP_DIR/exp_uaf_quarantine.c" -o "$EXP_DIR/exp_uaf_quarantine"

echo "----------------------------------------"
echo "Far OOB"
"$EXP_DIR/exp_far_oob" > "$LOG_DIR/fn_far_oob.log" 2>&1
if [ $? -eq 0 ]; then 
    echo "False Negative achieved." 
else 
    echo "Caught by ASan." 
fi

echo "----------------------------------------"
echo "Unaligned"
"$EXP_DIR/exp_unaligned" > "$LOG_DIR/fn_unaligned.log" 2>&1
if [ $? -eq 0 ]; then 
    echo "False Negative achieved." 
else 
    echo "Caught by ASan." 
fi

echo "----------------------------------------"
echo "UAF Quarantine"
"$EXP_DIR/exp_uaf_quarantine" > "$LOG_DIR/fn_uaf_quarantine.log" 2>&1
if [ $? -eq 0 ]; then 
    echo "False Negative achieved." 
else 
    echo "Caught by ASan." 
fi

echo "----------------------------------------"
echo "All tests completed."
set -e