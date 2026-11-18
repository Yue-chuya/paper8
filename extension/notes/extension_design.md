# Extension Experiment
Student ID: 1240028451
Name: Yuan Xinyi

Single modified factor: heap red‑zone size
Baseline setting: heap redzone size = 128 bytes (AddressSanitizer default)
Modified setting: heap redzone size = 32 bytes
All other configurations remain unchanged: quarantine size(256MB), stack unwinding depth(30), compiler, benchmark workload, OS and hardware.

Goal: Compare memory overhead, binary performance slowdown and bug‑detection capability between default redzone(128B) and smaller redzone(32B).
