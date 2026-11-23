# Makefile for AddressSanitizer Reproduction

# define
CC = clang
CFLAGS_BASE = -O2
CFLAGS_ASAN_BUG = -O0 -fsanitize=address -g
CFLAGS_ASAN_PERF = -O2 -fsanitize=address

WORKLOAD_DIR = experiments/workload
BUG_DIR = experiments/bug_tests
FN_DIR = experiments/false_negative

# 1. compile all code
all: workload extension bug_tests false_negatives
	@echo "Build complete! Run 'make run' to execute all experiments."

# 2. compile benchmark (gemm)。
workload:
	$(CC) $(CFLAGS_BASE) $(WORKLOAD_DIR)/gemm.c -o $(WORKLOAD_DIR)/demo_baseline
	$(CC) $(CFLAGS_ASAN_PERF) $(WORKLOAD_DIR)/gemm.c -o $(WORKLOAD_DIR)/demo_asan

# 3. compile Extension (malloc) 
extension:
	$(CC) $(CFLAGS_BASE) $(WORKLOAD_DIR)/malloc.c -o $(WORKLOAD_DIR)/demo_baseline_malloc
	$(CC) $(CFLAGS_ASAN_PERF) $(WORKLOAD_DIR)/malloc.c -o $(WORKLOAD_DIR)/demo_asan_malloc

# 4. compile Bug tests (-O0)
bug_tests:
	$(CC) $(CFLAGS_ASAN_BUG) $(BUG_DIR)/exp_use_after_free.c -o $(BUG_DIR)/exp_use_after_free
	$(CC) $(CFLAGS_ASAN_BUG) $(BUG_DIR)/exp_heap.c -o $(BUG_DIR)/exp_heap
	$(CC) $(CFLAGS_ASAN_BUG) $(BUG_DIR)/exp_double_free.c -o $(BUG_DIR)/exp_double_free
	$(CC) $(CFLAGS_ASAN_BUG) $(BUG_DIR)/exp_stack.c -o $(BUG_DIR)/exp_stack
	$(CC) $(CFLAGS_ASAN_BUG) $(BUG_DIR)/exp_global.c -o $(BUG_DIR)/exp_global

# 5. compile False Negatives tests (-O0)
false_negatives:
	$(CC) $(CFLAGS_ASAN_BUG) $(FN_DIR)/exp_far_oob.c -o $(FN_DIR)/exp_far_oob
	$(CC) $(CFLAGS_ASAN_BUG) $(FN_DIR)/exp_unaligned.c -o $(FN_DIR)/exp_unaligned
	$(CC) $(CFLAGS_ASAN_BUG) $(FN_DIR)/exp_uaf_quarantine.c -o $(FN_DIR)/exp_uaf_quarantine

# 6. run all experiments
run: all
	@echo "---------- Starting all experiments ----------"
	@echo "----- Running Main Benchmark -----"
	@bash scripts/run_benchmark.sh
	@bash scripts/run_paper_params.sh
	@echo "----- Running Bug Tests -----"
	@bash scripts/run_bug_tests.sh
	@echo "----- Running Extension -----"
	@bash scripts/run_extension.sh
	@bash scripts/run_extension_bug_tests.sh
	@echo "----- Running False Negatives -----"
	@bash scripts/run_false_negative.sh
	@echo "----- Generating Figures -----"
	@python3 scripts/plot_runtime.py
	@python3 scripts/plot_memory.py
	@python3 scripts/plot_extension.py
	@echo "All experiments completed. Please check 'results/' and 'logs/' for data. Please check 'figure/' for generated figures."

# 7. clean
clean:
	@echo "Cleaning up binaries and debug symbols"
	rm -f $(WORKLOAD_DIR)/demo_baseline $(WORKLOAD_DIR)/demo_asan 
	rm -f $(WORKLOAD_DIR)/demo_baseline_malloc $(WORKLOAD_DIR)/demo_asan_malloc
	rm -f $(BUG_DIR)/exp_use_after_free $(BUG_DIR)/exp_heap
	rm -f $(BUG_DIR)/exp_double_free $(BUG_DIR)/exp_stack $(BUG_DIR)/exp_global
	rm -f $(FN_DIR)/exp_far_oob $(FN_DIR)/exp_unaligned $(FN_DIR)/exp_uaf_quarantine
	rm -rf experiments/*/*.dSYM
	@echo "Clean complete."