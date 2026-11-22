# Extension Experiment Result
**Single Modified Factor:** Redzone Size (128B vs 32B)

## Raw Data
- Baseline Times:      0.002650000 0.003326000 0.002659000
- ASan(128B) Times:    0.003499000 0.003780000 0.003503000
- ASan(32B) Times:     0.003423000 0.003519000 0.003465000
- Baseline Peak Mem:   1.55 1.50 1.50
- ASan(128B) Peak Mem: 35.70 35.72 35.73
- ASan(32B) Peak Mem:  35.72 35.64 35.72

## Statistics & Comparison
- **128B Redzone**
  - Slowdown: **24.86%** (1.25x)
  - Memory Ratio: **23.55x**

- **32B Redzone**
  - Slowdown: **20.52%** (1.21x)
  - Memory Ratio: **23.53x**
