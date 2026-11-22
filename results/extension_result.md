# Extension Experiment Result
**Single Modified Factor:** Heap Redzone Size (128B vs 32B)

## Raw Data
- Baseline Times: 0.003142000 0.003496000 0.002610000
- ASan(128B) Times: 0.003812000 0.003708000 0.003465000
- ASan(32B) Times: 0.003452000 0.003453000 0.003580000
- Baseline Peak Mem: 1.42 1.42 1.42
- ASan(128B) Peak Mem: 35.73 35.72 35.73
- ASan(32B) Peak Mem: 35.72 35.73 35.69

## Statistics & Comparison
--- 128B Redzone (Default) ---
Slowdown: 18.78% (1.19x)
Memory Ratio: 25.16x

--- 32B Redzone (Extension) ---
Slowdown: 13.38% (1.13x)
Memory Ratio: 25.15x
