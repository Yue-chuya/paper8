# Controlled Re-run: Paper's Evaluation Parameters

## Configuration
- ASAN_OPTIONS: quarantine_size_mb=0:redzone=32:malloc_context_size=0

## Raw Data
- Baseline Times: 1.519876 1.571691 1.564978
- ASan Times: 2.585575 2.554255 2.590561
- Baseline Peak Mem (MB): 24.38 24.30 24.38
- ASan Peak Mem (MB): 61.00 61.02 61.00

## Statistics
Baseline Mean: 1.5522 s
ASan Mean: 2.5768 s
Ratio: 1.66x
Slowdown: 66.01%
Baseline Peak Mem: 24.35 MB
ASan Peak Mem: 61.01 MB
Memory Ratio: 2.51x
