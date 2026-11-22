# Paper's Evaluation Parameters

## Configuration
- ASAN_OPTIONS: quarantine_size_mb=0:redzone=32:malloc_context_size=0

## Raw Data
- Baseline Times:         1.528668 1.494263 1.538846
- ASan Times:             2.563810 2.569080 2.567682
- Baseline Peak Mem (MB): 24.38 24.30 24.30
- ASan Peak Mem (MB):     61.00 60.98 61.00

## Statistics
- Baseline Mean: 1.5206 s
- ASan Mean: 2.5669 s
- Ratio: 1.69x
- Slowdown: 68.81%
- Baseline Peak Mem: 24.33 MB
- ASan Peak Mem: 60.99 MB
- Memory Ratio: 2.51x
