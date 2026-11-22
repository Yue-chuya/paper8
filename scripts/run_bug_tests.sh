#!/bin/bash

cd "$(dirname "$0")/.."
EXP_DIR="experiments/bug_tests"
LOG_DIR="logs/bug_tests"
mkdir -p "$LOG_DIR"
declare -a tests=("exp_use_after_free" "exp_heap" "exp_double_free" "exp_stack" "exp_global")

echo "Running ASan Bug Detection Tests (-O0)"
set +e

for test in "${tests[@]}"; do
    echo "----------------------------------------"
    echo "Testing: $test"
    clang -O0 -fsanitize=address -g "$EXP_DIR/$test.c" -o "$EXP_DIR/$test"
    "$EXP_DIR/$test" > "$LOG_DIR/${test}.log" 2>&1
    
    if [ $? -ne 0 ]; then
        echo "Bug WAS detected."
    else
        echo "Bug NOT detected."
    fi
done

echo "----------------------------------------"
echo "All tests completed."
set -e