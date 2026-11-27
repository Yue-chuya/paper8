# Extension result
### Threads = 1
#### Raw Data
- Baseline:            1.483732 1.481453 1.482586
- ASan:                2.579997 2.819688 2.753381
- Baseline Peak Mem (MB): 24.38 24.38 24.38
- ASan Peak Mem (MB):     61.53 61.56 61.50

#### Statistics
- Baseline Mean: 1.4826 s, Std: 0.0011
- ASan Mean: 2.7177 s, Std: 0.1238
- Ratio: 1.83x
- Slowdown: 83.31%
- Baseline Peak Mem Mean: 24.38 MB
- ASan Peak Mem Mean: 61.53 MB
- Memory Ratio: 2.52x

### Threads = 2
#### Raw Data
- Baseline:            0.771920 0.985738 0.979364
- ASan:                1.460373 2.143253 2.226497
- Baseline Peak Mem (MB): 24.38 24.34 24.34
- ASan Peak Mem (MB):     61.61 61.59 61.62

#### Statistics
- Baseline Mean: 0.9123 s, Std: 0.1216
- ASan Mean: 1.9434 s, Std: 0.4204
- Ratio: 2.13x
- Slowdown: 113.01%
- Baseline Peak Mem Mean: 24.35 MB
- ASan Peak Mem Mean: 61.61 MB
- Memory Ratio: 2.53x

### Threads = 4
#### Raw Data
- Baseline:            0.576288 0.573793 0.599901
- ASan:                1.120423 1.111297 1.156769
- Baseline Peak Mem (MB): 24.38 24.41 24.38
- ASan Peak Mem (MB):     61.62 61.64 61.66

#### Statistics
- Baseline Mean: 0.5833 s, Std: 0.0144
- ASan Mean: 1.1295 s, Std: 0.0241
- Ratio: 1.94x
- Slowdown: 93.63%
- Baseline Peak Mem Mean: 24.39 MB
- ASan Peak Mem Mean: 61.64 MB
- Memory Ratio: 2.53x

### Threads = 8
#### Raw Data
- Baseline:            0.503416 0.469743 0.481191
- ASan:                0.979274 0.969551 0.999086
- Baseline Peak Mem (MB): 24.45 24.45 24.44
- ASan Peak Mem (MB):     61.72 61.70 61.75

#### Statistics
- Baseline Mean: 0.4848 s, Std: 0.0171
- ASan Mean: 0.9826 s, Std: 0.0151
- Ratio: 2.03x
- Slowdown: 102.70%
- Baseline Peak Mem Mean: 24.45 MB
- ASan Peak Mem Mean: 61.72 MB
- Memory Ratio: 2.52x
## Verification
| Item | Value |
| --- | --- |
| checksum pthread (1 thread) | 249500249.99999997 |
| checksum pthread (8 threads) | 249500249.99999997 |
| checksum_match | yes |
## Summary Table
| label | threads | min_s | mean_s | std_s | peak_mem_mb | memory_ratio | speedup | slowdown |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| serial | 1 | 1.488448 | 1.493021 | 0.004206 | NA | NA | 1.00 | - |
| serial_asan | 1 | 2.595729 | 2.624101 | 0.025472 | 0.00 | NA | 1.00 | 1.76x |
| pthread | 1 | 1.481453 | 1.482590 | 0.001140 | 24.38 | NA | 1.01 | - |
| pthread_asan | 1 | 2.579997 | 2.717689 | 0.123768 | 61.56 | 2.53 | 0.97 | 1.83x |
| pthread | 2 | 0.771920 | 0.912341 | 0.121650 | 24.38 | NA | 1.64 | - |
| pthread_asan | 2 | 1.460373 | 1.943374 | 0.420357 | 61.62 | 2.53 | 1.35 | 2.13x |
| pthread | 4 | 0.573793 | 0.583327 | 0.014407 | 24.41 | NA | 2.56 | - |
| pthread_asan | 4 | 1.111297 | 1.129496 | 0.024056 | 61.66 | 2.53 | 2.32 | 1.94x |
| pthread | 8 | 0.469743 | 0.484783 | 0.017122 | 24.45 | NA | 3.08 | - |
| pthread_asan | 8 | 0.969551 | 0.982637 | 0.015052 | 61.75 | 2.53 | 2.67 | 2.03x |
