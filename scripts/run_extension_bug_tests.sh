#!/bin/bash

cd "$(dirname "$0")/.."
EXP_DIR="experiments/false_negative"
LOG_DIR="logs"

mkdir -p "$LOG_DIR"
set +e
echo "=== Extension: Redzone Size vs Bug-Detection Capability ==="

echo "Compiling exp_far_oob.c (-O0 to prevent optimization)..."
clang -O0 -fsanitize=address -g "$EXP_DIR/exp_far_oob.c" -o "$EXP_DIR/exp_far_oob"

echo -e "\n--- [Test 1] Running with redzone=32 (Expect: False Negative) ---"
ASAN_OPTIONS=redzone=32 "$EXP_DIR/exp_far_oob" > "$LOG_DIR/far_oob_32.log" 2>&1

if [ $? -eq 0 ]; then
    echo "Result: Bug WAS detected. (Unexpected for 32B redzone)"
else
    echo "Result: Bug NOT detected (False Negative). Program survived."
fi

echo -e "\n--- [Test 2] Running with redzone=128 (Expect: True Positive) ---"
ASAN_OPTIONS=redzone=128 "$EXP_DIR/exp_far_oob" > "$LOG_DIR/far_oob_128.log" 2>&1

if [ $? -ne 0 ]; then
    echo "Result: Bug WAS detected (True Positive)!"
else
    echo "Result: Bug NOT detected. (Unexpected for 128B redzone)"
fi

echo "Extension Bug Test Completed."
echo "Raw logs saved in $LOG_DIR/far_oob_32.log and far_oob_128.log"

set -e