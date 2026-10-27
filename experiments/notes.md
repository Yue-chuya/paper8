# Week1 ASan minimal demo notes
Environment
- OS: Ubuntu 22.04(WSL2)
- Clang version:Ubuntu clang version 21.1.8 (6ubuntu1) 

## Commands
```bash
clang -fsanitize=address -g minimal_demo.c -o demo_asan
./demo_asan
## ASan execution output
==600==ERROR: AddressSanitizer: heap-use-after-free on address 0x6f3bb13e0010 at pc 0x649cae906b4a bp 0x7ffcc5bdd370 sp 0x7ffcc5bdd368
READ of size 4 at 0x6f3bb13e0010 thread T0
==600==WARNING: invalid path to external symbolizer!
==600==WARNING: Failed to use and restart external symbolizer!
    #0 0x649cae906b49  (/home/yuanxinyi/paper8/experiments/demo_asan+0x115b49) (BuildId: 97339cc9147c18e866edde5fec376bd6930219ba)
    #1 0x731bb202a600  (/usr/lib/x86_64-linux-gnu/libc.so.6+0x2a600) (BuildId: 066527e430a32768d82741e00b81eebb1a872294)
    #2 0x731bb202a717  (/usr/lib/x86_64-linux-gnu/libc.so.6+0x2a717) (BuildId: 066527e430a32768d82741e00b81eebb1a872294)
    #3 0x649cae81d364  (/home/yuanxinyi/paper8/experiments/demo_asan+0x2c364) (BuildId: 97339cc9147c18e866edde5fec376bd6930219ba)

0x6f3bb13e0010 is located 0 bytes inside of 4-byte region [0x6f3bb13e0010,0x6f3bb13e0014)
freed by thread T0 here:
    #0 0x649cae8c266a  (/home/yuanxinyi/paper8/experiments/demo_asan+0xd166a) (BuildId: 97339cc9147c18e866edde5fec376bd6930219ba)
    #1 0x649cae906b14  (/home/yuanxinyi/paper8/experiments/demo_asan+0x115b14) (BuildId: 97339cc9147c18e866edde5fec376bd6930219ba)
    #2 0x731bb202a600  (/usr/lib/x86_64-linux-gnu/libc.so.6+0x2a600) (BuildId: 066527e430a32768d82741e00b81eebb1a872294)
    #3 0x731bb202a717  (/usr/lib/x86_64-linux-gnu/libc.so.6+0x2a717) (BuildId: 066527e430a32768d82741e00b81eebb1a872294)
    #4 0x649cae81d364  (/home/yuanxinyi/paper8/experiments/demo_asan+0x2c364) (BuildId: 97339cc9147c18e866edde5fec376bd6930219ba)

previously allocated by thread T0 here:
    #0 0x649cae8c2908  (/home/yuanxinyi/paper8/experiments/demo_asan+0xd1908) (BuildId: 97339cc9147c18e866edde5fec376bd6930219ba)
    #1 0x649cae906ac8  (/home/yuanxinyi/paper8/experiments/demo_asan+0x115ac8) (BuildId: 97339cc9147c18e866edde5fec376bd6930219ba)
    #2 0x731bb202a600  (/usr/lib/x86_64-linux-gnu/libc.so.6+0x2a600) (BuildId: 066527e430a32768d82741e00b81eebb1a872294)
    #3 0x731bb202a717  (/usr/lib/x86_64-linux-gnu/libc.so.6+0x2a717) (BuildId: 066527e430a32768d82741e00b81eebb1a872294)
    #4 0x649cae81d364  (/home/yuanxinyi/paper8/experiments/demo_asan+0x2c364) (BuildId: 97339cc9147c18e866edde5fec376bd6930219ba)

SUMMARY: AddressSanitizer: heap-use-after-free (/home/yuanxinyi/paper8/experiments/demo_asan+0x115b49) (BuildId: 97339cc9147c18e866edde5fec376bd6930219ba)
Shadow bytes around the buggy address:
  0x6f3bb13dfd80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  0x6f3bb13dfe00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  0x6f3bb13dfe80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  0x6f3bb13dff00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  0x6f3bb13dff80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
=>0x6f3bb13e0000: fa fa[fd]fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x6f3bb13e0080: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x6f3bb13e0100: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x6f3bb13e0180: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x6f3bb13e0200: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x6f3bb13e0280: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
Shadow byte legend (one shadow byte represents 8 application bytes):
  Addressable:           00
  Partially addressable: 01 02 03 04 05 06 07
  Heap left redzone:       fa
  Freed heap region:       fd
  Stack left redzone:      f1
  Stack mid redzone:       f2
  Stack right redzone:     f3
  Stack after return:      f5
  Stack use after scope:   f8
  Global redzone:          f9
  Global init order:       f6
  Poisoned by user:        f7
  Container overflow:      fc
  Array cookie:            ac
  Intra object redzone:    bb
  ASan internal:           fe
  Left alloca redzone:     ca
  Right alloca redzone:    cb
==600==ABORTING
