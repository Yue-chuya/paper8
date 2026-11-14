#!/bin/bash

cd "$(dirname "$0")/.."
EXP_DIR="experiments"
LOG_DIR="logs"

mkdir -p "$LOG_DIR"

declare -a tests=("minimal_demo" "exp_oob" "exp_double_free" "exp_malloc_zero")

echo "=== Running ASan Bug Detection Tests (-O0) ==="
set +e

for test in "${tests[@]}"; do
    echo "----------------------------------------"
    echo "Testing: $test"
    
    clang -O0 -fsanitize=address -g "$EXP_DIR/$test.c" -o "$EXP_DIR/$test"
    
    "$EXP_DIR/$test" > "$LOG_DIR/${test}.log" 2>&1
    
    if [ $? -ne 0 ]; then
        echo "Bug detected in $test! Log saved to logs/${test}.log"
    else
        echo "No bug detected in $test (maybe optimized out?)."
    fi
done

echo "----------------------------------------"
echo "All tests completed."
set -e