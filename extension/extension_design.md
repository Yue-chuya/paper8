# Extension Experiment
Student ID: 1240028451
Name: Yuan Xinyi

We conduct two independent single-factor experiments. No experiment modifies two parameters at the same time. In each test run, only one factor is changed, and all other settings remain fixed for valid comparison.

## Experiment 1: Heap redzone size
Baseline setting: heap redzone size = 128 bytes
Modified setting: heap redzone size = 32 bytes
Fixed parameters: quarantine size(256MB), stack unwinding depth(30), compiler, benchmark workload, OS and hardware.
Goal: Compare memory overhead, runtime slowdown and bug-detection capability between 128B and 32B redzone.

## Experiment 2: Quarantine size
Baseline setting: quarantine size = 256MB
Modified setting: quarantine size = 64MB
Fixed parameters: heap redzone size(128B), stack unwinding depth(30), compiler, benchmark workload, OS and hardware.
Goal: Compare memory overhead, runtime slowdown and bug-detection capability between 256MB and 64MB quarantine.
