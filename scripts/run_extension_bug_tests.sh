#!/bin/bash

cd "$(dirname "$0")/.."
EXP_DIR="experiments/false_negative"
LOG_DIR="logs/extension_bug_tests"
mkdir -p "$LOG_DIR"
set +e

echo "Redzone Size vs Bug-Detection Capability"
echo "----------------------------------------"
clang -O0 -fsanitize=address -g "$EXP_DIR/exp_far_oob.c" -o "$EXP_DIR/exp_far_oob"

echo -e "----- Running with redzone=32 -----"
ASAN_OPTIONS=redzone=32 "$EXP_DIR/exp_far_oob" > "$LOG_DIR/far_oob_32.log" 2>&1
if [ $? -eq 0 ]; then
    echo "Bug NOT detected."
else
    echo "Bug WAS detected."
fi

echo -e "----- Running with redzone=128 -----"
ASAN_OPTIONS=redzone=128 "$EXP_DIR/exp_far_oob" > "$LOG_DIR/far_oob_128.log" 2>&1
if [ $? -ne 0 ]; then
    echo "Bug WAS detected."
else
    echo "Bug NOT detected."
fi

echo "----------------------------------------"
echo "Extension Bug Test Completed."
set -e