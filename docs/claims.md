# Claims
## 1.Design & Mechanism
### Claims 1.1:
 It employs a specialized memory allocator and code instrumentation that is simple enough to be implemented in any compiler, binary translation system, or even in hardware.
#### - location: Abstract
### support:
- In both cases the instrumentation inserts only one memory read for each memory access in the original code.
- Here we give two examples of instrumentation on x86 64 (8-
and 4- byte stores).
C program:
```
void foo(T *a) {
*a = 0x1234;
}
```
#### -support location: Section 3.2 & Appendix

### Claims 1.2:
 present a novel shadow state encoding that enables compact shadow memory - as much as a 128-to-1 mapping - for detecting out-of-bounds and use-after-free bugs;
#### - location: Section 1.1
### support:
- AddressSanitizer dedicates one-eighth of the virtual address space to its shadow memory and uses a direct mapping with a scale and offset to translate an application address to its corresponding shadow address. Given the application memory address Addr, the address of the shadow byte is computed as (Addr>>3)+Offset.
#### -support location: Section 3.1

### Claims 1.3:
 In short, AddressSanitizer has no false positives.
#### - location: Section 3.6
### support:
- To avoid this problem we partially disabled load widening in LLVM when AddressSanitizer instrumentation is
enabled.
- Finally, without exiting the function and un-poisoning the redzones,
the child process calls a function that never returns (e.g.,
exit or exec). As a result, part of the parent address
space remains poisoned and AddressSanitizer reports an
error later when this memory is reused. We solved this
problem by finding never return function calls (functions like exit or exec have this attribute) and unpoisoning the entire stack memory before the call.
#### -support location: Section 3.6.1 & Section 3.6.2

## 2.Performance & Overhead
### Claims 2.1:
 Its average slowdown is just
 73% yet it accurately detects bugs at the point of occurrence.
#### - location: Abstract
### support:
- Figure 2 shows that the average slowdown on
CPU2006 is 73%.
#### -support location: Section 4 & Figure 2

### Claims 2.2:
 We also measured AddressSanitizer performance when only writes are instrumented: the average slowdown is 26%.
#### - location: Section 4
### support:
- no text description.
#### -support location: Section 4 & Figure 2

### Claims 2.3:
 The average memory usage increase is 3.37x.
#### - location: Section 4
### support:
- total: Original = 8171 MB, Instrumented = 24467 MB, Increase = 3.37x.
#### -support location: Table 1

### Claims 2.4:
 Only 6 benchmarks had a noticeable stack size change and only 3 benchmarks had stack size increases over 10%.
#### - location: Section 4
### support:
- no text description.
#### -support location: Table 2

### Claims 2.5:
 The binary size increase on SPEC CPU2006 ranges from 1.5x to 3.2x, with an average of 2.5x.
#### - location: Abstract
### support:
- no text description.
#### -support location: Table 2

## 3.Deployment & Effectiveness
### Claims 3.1:
 It has found over 300 previously unknown bugs in the Chromium browser and many bugs in other software.
#### - location: Abstract
### support:
-  In the first 10 months of testing the
tool detected over 300 previously unknown bugs in the
Chromium code and in third-party libraries. 210 bugs
were heap-use-after-free, 73 were heap-buffer-overflow,
8 global-buffer-overflow, 7 stack-buffer-overflow and 1
memcpy parameter overlap. 
#### -support location: Section 4.2

### Claims 3.2:
 Three bugs were found in CPU2006: one stack and
one global buffer overflow in h264ref, and a use-afterrealloc in perlbench.
#### - location: Section 4
### support:
- experiment conclusion
#### -support location: Section 4

## 4.Comparison
### Claims 4.1:
 Valgrind and Dr. Memory incur 20x and 10x slowdowns on CPU2006, respectively [8]. But these tools detect a different set of bugs (in addition to out-of-bounds and use-after-free they detect uninitialized reads and memory leaks, but do not handle out-of-bounds for most stack variables and globals).
#### - location: Section 4.1
### support:
- [8] Derek Bruening and Qin Zhao. Practical memory checking with
Dr. Memory. In Proc. of the International Symposium on Code
Generation and Optimization (CGO ’11), pages 213–223, April
2011.
#### -support location: References

### Claims 4.2:
 According to our measurements, Mudflap’s slowdown on CPU2006 ranges from 2x to 41x; several benchmarks fail with out-of-memory errors.
#### - location: Section 4.1
### support:
- experiment conclusion
#### -support location: Section 4

### Claims 4.3:
 Duma, the freely available guard page implementation for Linux, crashed on 12 out of 18 CPU2006 benchmarks with out-of-memory errors. No surprise: the Duma manual describes it as a 'terrible memory hog'.
#### - location: Section 4.1
### support:
- experiment conclusion
#### -support location: Section 4

## 5.Limitations / False Negatives
### Claims 5.1:
 The instrumentation scheme described above may miss a very rare type of bug: an unaligned access that is partially out-of-bounds.
#### - location: Section 3.5
### support:
```
int *a = new int[2]; // 8-aligned
int *u = (int*)((char*)a + 6);
*u = 1; // Access to range [6-9]
```
#### -support location: Section 3.5

### Claims 5.2:
 First, if an out-of-bounds access touches memory too far away from the object bound it may land in a different valid allocation and the bug will be missed.
#### - location: Section 3.5
### support:
```
char *a = new char[100];
char *b = new char[1000];
a[500] = 0; // may end up somewhere in b
```
#### -support location: Section 3.5

### Claims 5.3:
 Second, a use-after-free may not be detected if a large amount of memory has been allocated and deallocated between the “free“ and the following use.
#### - location: Section 3.5
### support:
```
char *a = new char[1 << 20]; // 1MB
delete [] a; // <<< "free"
char *b = new char[1 << 28]; // 256MB
delete [] b; // drains the quarantine queue.
char *c = new char[1 << 20]; // 1MB
a[0] = 0; // "use". May land in ’c’.
```
#### -support location: Section 3.5