# Experimental Deviations: Original Paper vs. Our Reproduction

**Document type:** Deviation register for a course-level reproduction of *AddressSanitizer: A Fast Address Sanity Checker* (Serebryany et al., USENIX ATC 2012)
**Last updated:** 2026-11-07
**Status:** Consolidated — environment, benchmark substitution, runtime results and Claim 2.1 verdict are settled. Items that still depend on runtime-configuration measurement are listed in Section 8.

---

## 1. Purpose and Scope Statement

This document records, item by item, how our reproduction differs from the experimental setup reported in Section 4 (Evaluation) of the original paper, why each difference exists, and what it means for the validity of the claims we assess.

**Scope statement (use this wording verbatim in the report):**

> Because SPEC CPU2006 was not obtainable under the applicable licensing and access restrictions, we did not evaluate the full SPEC CPU2006 benchmark suite. Instead we reproduce the AddressSanitizer runtime-overhead claim on a single working set — the GEMM kernel from PolyBench/C 4.2.1 — under a controlled compiler and platform environment. Our study is therefore a **reduced-scale reproduction (缩小规模复现)** of the paper's evaluation, not an exact replication of its SPEC CPU2006 results.

This framing governs every comparison below: numerical agreement with the paper is reported as *consistency*, not as *reproduction of the paper's averaged figures*.

---

## 2. Original Experimental Setup (Paper, Section 4)

| Item | Original paper setting |
|---|---|
| Benchmark suite | SPEC CPU2006 (C and C++ benchmarks) |
| Platform | 64-bit mode |
| Machine | HP Z600 |
| CPU | 2 × quad-core Intel Xeon E5620 |
| Memory | 24 GB RAM |
| Baseline compiler | Regular LLVM compiler |
| Baseline compilation | `clang -O2` |
| ASan build | AddressSanitizer-instrumented binaries |
| Heap redzone size | 32 bytes |
| Stack unwinding | Disabled during `malloc` and `free` |
| Quarantine size | 0 |
| Average runtime slowdown | 73% on SPEC CPU2006 |
| Average memory usage increase | 3.37× |

**Reading note.** The four rows *heap redzone = 32 bytes*, *stack unwinding disabled during `malloc`/`free`*, *quarantine size = 0* and *`clang -O2`* are the **evaluation-time** settings of Section 4. Section 4.3 separately discusses ASan's default values and tuning knobs; those defaults must not be substituted for the evaluation settings when making comparisons.

---

## 3. Paper vs. Our Reproduction

| Item | Original paper | Our reproduction (confirmed) | Deviation and its effect on validity |
|---|---|---|---|
| Benchmark suite | SPEC CPU2006 | **PolyBench/C 4.2.1** | **Substituted.** SPEC CPU2006 could not be obtained (licensing/access restrictions). Consequence: no cross-benchmark average can be produced; suite-level comparability is lost. |
| Workload | Multiple SPEC CPU2006 C/C++ benchmarks | **GEMM (dense matrix multiplication)** | **Reduced scope.** One compute-bound kernel instead of a mixed integer/floating-point, memory- and branch-heavy suite. |
| Operating system | 64-bit Linux | **Ubuntu on WSL2** | Virtualised Linux on a Windows host; syscall and allocator paths differ from bare-metal Linux, which can shift ASan's shadow-memory and `mmap` behaviour. |
| Compiler | Regular LLVM compiler (paper era, c. 2011–2012) | **Ubuntu clang 21.1.8** | Roughly a decade and a half of compiler evolution separates the two toolchains; inlining, vectorisation and instruction scheduling all differ, so the *baseline-to-ASan ratio* is not guaranteed to match the paper's. |
| Baseline compilation | `clang -O2` | **`clang -O2`** | Matches the paper's optimisation level. |
| ASan compilation | ASan-instrumented binaries at `-O2` | **`clang -O2 -fsanitize=address`** | Matches in optimisation level and instrumentation switch. |
| Heap redzone | 32 bytes | Not yet measured (see §8) | Paper used a non-default 32-byte redzone; if our run used ASan's default, part of any residual gap is attributable to configuration rather than to the workload. |
| Stack unwinding during `malloc`/`free` | Disabled | Not yet measured (see §8) | Same caveat: unwinding cost would inflate our ASan timing if it remained enabled. |
| Quarantine size | 0 | Not yet measured (see §8) | Same caveat: a non-zero quarantine raises peak RSS and can perturb allocator locality. |
| Baseline runtime | Suite measurements (average) | **1.18 s (GEMM)** | Single measurement on one kernel — not an average over 20+ benchmarks. |
| ASan runtime | Suite measurements (average) | **1.99 s (GEMM)** | Same as above. |
| Runtime ratio | ≈ 1.73× (73% slowdown) | **≈ 1.69× (68.6% slowdown)** | Numerically close (Δ ≈ 4.4 percentage points), but the two numbers answer different questions: the paper's is a suite average, ours is one kernel's single figure. |
| Memory overhead | 3.37× average | Not measured (see §8) | No reproduction value exists; memory overhead is outside the scope of what we currently claim. |

**Summary of deviations by type**

1. **Forced substitution** — benchmark suite (SPEC CPU2006 → PolyBench/C 4.2.1 GEMM), driven by licensing/access constraints. This is the single deviation that most limits the strength of our conclusion.
2. **Environmental** — WSL2 vs. bare-metal, and clang 21.1.8 vs. the paper's historical LLVM. Affects absolute timings and possibly the ratio.
3. **Configuration fidelity (open)** — redzone, unwinding and quarantine are not yet confirmed on our side; until they are, the ratio comparison carries an unquantified configuration component.
4. **Matched by design** — optimisation level (`-O2`) and the ASan instrumentation switch itself.

---

## 4. Runtime Overhead: Measurements and Calculation

### 4.1 Environment and build configuration (confirmed)

| Field | Value |
|---|---|
| Platform | Ubuntu (WSL2) |
| Compiler | Ubuntu clang 21.1.8 |
| Baseline build | `clang -O2` |
| ASan build | `clang -O2 -fsanitize=address` |
| Workload | PolyBench/C 4.2.1 — GEMM |
| Baseline wall-clock | 1.18 s |
| ASan wall-clock | 1.99 s |

### 4.2 Derived quantities

Runtime ratio:

`1.99 / 1.18 = 1.6864… ≈ 1.69×`

Slowdown (relative increase over baseline):

`(1.99 − 1.18) / 1.18 × 100% = 68.64…% ≈ 68.6%`

Comparison with the paper:

| Quantity | Paper (SPEC CPU2006) | Ours (GEMM) | Gap |
|---|---|---|---|
| Ratio | ≈ 1.73× | ≈ 1.69× | ≈ 0.04× |
| Slowdown | 73% | 68.6% | ≈ 4.4 percentage points |

### 4.3 Interpretation and limitation

The measured slowdown lands within roughly 4.4 percentage points of the paper's averaged figure, on the low side. Three candidate explanations, none of which we can separate with the current data:

- **Workload composition.** GEMM is a regular, cache-friendly, compute-bound kernel with a small and stable live set; ASan's instrumentation cost per memory access is partly amortised by the arithmetic intensity, which typically pulls the ratio below a mixed-workload average.
- **Compiler generation.** clang 21.1.8 applies far more aggressive optimisation than the paper's toolchain, so both binaries differ from the paper's in ways that need not cancel out in the ratio.
- **Configuration.** If our run used ASan defaults (16-byte redzone, non-zero quarantine, unwinding enabled) rather than the paper's evaluation settings, the effect could point either way and is currently unquantified.

**What this result is:** a consistent, correctly signed, order-of-magnitude-correct observation that ASan imposes a substantial runtime cost — here about 69% on a compute-bound kernel.

**What this result is not:** a reproduction of the paper's 73% *average across SPEC CPU2006*. It is a single-kernel measurement and must be labelled as such wherever the number appears.

**Measurement caveat.** The 1.18 s and 1.99 s figures are currently reported without a stated repetition protocol. Before these numbers are treated as a formal result, the repetition count, the aggregation rule (median vs. best-of-n) and the timer resolution should be recorded. See §8.

---

## 5. Reasons for the Known Deviations

### 5.1 Benchmark replacement: from SPEC CPU2006 to PolyBench/C 4.2.1 GEMM

**Fact.** SPEC CPU2006 is distributed commercially by the Standard Performance Evaluation Corporation and requires a paid licence; it also ships as ISO images that must be obtained through that channel. Our group had neither a licence nor legitimate access to the media, and using an unlicensed copy was not an option. We therefore selected a freely redistributable, academically standard alternative: **PolyBench/C 4.2.1**, and within it the **GEMM** kernel.

**Why GEMM.** GEMM is the canonical dense linear-algebra kernel; it is compute-bound with a compact, predictable working set, it is easy to build with a single translation unit and no external dependencies, and its runtime is stable enough that a two-run comparison (baseline vs. ASan) yields a clean ratio without long measurement windows. It is also the most widely cited PolyBench kernel, which makes our command lines and configuration reproducible for a reader.

**Cost of the substitution.** SPEC CPU2006 averages over integer and floating-point benchmarks with very different memory-access profiles — pointer-chasing (`mcf`, `astar`), large streaming working sets (`lbm`, `soplex`), branch-heavy code, and C++ object churn. ASan's overhead is sensitive to exactly these profile differences. A single compute-bound kernel therefore samples one point of the distribution, not its mean. Any comparison with "73%" must be read with this in mind, and the document states the substitution explicitly rather than presenting the numbers as if the suites were interchangeable.

**Reproduction depth achieved.** Reduced-scale reproduction: one workload, the paper's `-O2` optimisation level, the paper's ASan instrumentation mode, a modern compiler on WSL2 — sufficient to test the *direction and rough magnitude* of the runtime claim, insufficient to test the *suite-level average*.

### 5.2 Platform and compiler

The reproduction environment is **Ubuntu running under WSL2**, using **Ubuntu clang 21.1.8**. Compilation uses `clang -O2` for the baseline and `clang -O2 -fsanitize=address` for the ASan build.

Two consequences follow. First, WSL2 runs Linux in a lightweight VM, so the kernel, page-fault path and allocator interaction are close to but not identical with bare-metal Linux; absolute timings carry virtualisation noise, and ASan's large shadow-memory mapping can behave differently under WSL2's memory management. Second, the compiler is a recent clang rather than the ~2011-era LLVM used in the paper; this matters because ASan instrumentation interacts with inlining and vectorisation, and both have changed substantially since. Neither difference invalidates a same-machine, same-compiler A/B comparison — which is why our ratio is computed entirely within our own environment — but both weaken any claim that our absolute numbers or ratio should equal the paper's.

The exact Ubuntu release, kernel version, CPU model and available memory are not recorded here; they are not required for the A/B ratio but are listed in §8 for completeness of the experiment log.

---

## 6. Claim 2.1: Runtime Slowdown

**Claim under assessment.** AddressSanitizer incurs approximately 73% average runtime slowdown.

**Evidence assembled**

| Source | Value | Nature of the value |
|---|---|---|
| Original paper, Section 4 | 73% | Average over the SPEC CPU2006 suite |
| Our experiment | 68.6% (1.18 s → 1.99 s, ratio 1.69×) | Single GEMM kernel, PolyBench/C 4.2.1 |
| Difference | ≈ 4.4 percentage points | Directionally consistent, numerically close |

**Assessment.** Our GEMM measurement is of the same sign and the same order of magnitude as the paper's reported average, and the two figures sit within roughly 4.4 percentage points of each other. On the dimension the claim actually asserts — that ASan adds a large, roughly-two-thirds runtime cost rather than a negligible or catastrophic one — our independent measurement is consistent with the paper. The residual gap is attributable to workload composition, compiler generation and unverified runtime configuration, in proportions we cannot currently separate.

**Verdict: Supported.**

**Mandatory qualifier (carry this sentence with the verdict wherever it is reported):**

> The verdict *Supported* applies to the GEMM experiment conducted in this reproduction. It does not constitute a full reproduction of the 73% average reported for SPEC CPU2006, and must not be presented as one.

**Why not "Partially Supported".** A "partial" label would imply the evidence falls short of the claim's own assertion. The claim asserts a magnitude of average overhead; our data independently establish a magnitude of the same order on one workload. What is limited is the *generality* of the evidence, not the *direction or size* of the effect. The correct treatment is therefore a `Supported` verdict bounded by an explicit, prominent scope statement — which is exactly the qualifier above — rather than a weaker verdict that understates the agreement we do observe.

**What would upgrade this to a suite-level result.** Obtaining licensed SPEC CPU2006 media (or an equivalent mixed integer/floating-point suite with a documented reference average) and repeating the protocol of §4 across the full set, with the paper's evaluation-time redzone, unwinding and quarantine settings fixed. See §8.

---

## 7. Extension: Compiler Optimisation Level as an Independent Variable

### 7.1 Motivation

Our headline comparison holds the optimisation level fixed at `-O2` and varies only the instrumentation. That design answers "how much does ASan cost at the paper's optimisation level?" but not "does ASan's cost depend on how hard the compiler works?" The extension makes optimisation level a second independent variable, giving a 2 × 2 design over `{baseline, ASan} × {-O0, -O2}`.

The question it addresses: ASan instruments memory accesses, and the number of *executed* instrumented accesses depends on how the compiler schedules, vectorises and inlines the loop nest. If optimisation removes or coalesces accesses, the instrumentation density changes with the flag — so the ASan/baseline ratio is not necessarily invariant across optimisation levels.

### 7.2 Design

Workload, input size, machine, timer and repetition protocol are held identical across all four cells; only the compiler flags and the instrumentation switch vary.

| Cell | Configuration | Compile command |
|---|---|---|
| B-O0 | Baseline, no optimisation | `clang -O0 <gemm sources> -o gemm_O0` |
| B-O2 | Baseline, level 2 | `clang -O2 <gemm sources> -o gemm_O2` |
| A-O0 | ASan, no optimisation | `clang -O0 -fsanitize=address <gemm sources> -o gemm_O0_asan` |
| A-O2 | ASan, level 2 | `clang -O2 -fsanitize=address <gemm sources> -o gemm_O2_asan` |

Note that A-O2 and B-O2 reproduce the configurations of §4, so the extension re-measures the existing pair under the same protocol and doubles as a consistency check on 1.18 s / 1.99 s.

### 7.3 Procedure

1. Freeze the workload: same PolyBench/C 4.2.1 GEMM source, same matrix dimensions and data initialisation for all four cells.
2. Build all four binaries from the same source tree in one session; record the full command line and the `clang --version` output in the experiment log.
3. Warm-up: one untimed run per binary, discarded.
4. Measurement: ≥ 5 timed repetitions per binary, interleaved across cells (B-O0, B-O2, A-O0, A-O2, repeat) rather than run in blocks, so slow drift in machine load affects all cells similarly.
5. Aggregate: report median and min–max spread per cell. Record wall-clock with a monotonic timer.
6. Compute per optimisation level, exactly as in §4.2:

   - Ratio: `t(A-Ox) / t(B-Ox)`
   - Slowdown: `(t(A-Ox) − t(B-Ox)) / t(B-Ox) × 100%`

7. Cross-level comparison: plot slowdown against optimisation level (`-O0` vs. `-O2`) and state whether the ratio is level-invariant.

### 7.4 Results

| Cell | Median wall-clock (s) | Min–max (s) | Ratio vs. matching baseline | Slowdown |
|---|---|---|---|---|
| B-O0 | _pending_ | _pending_ | — | — |
| A-O0 | _pending_ | _pending_ | _pending_ | _pending_ |
| B-O2 | _pending_ (1.18 reported, single run) | _pending_ | — | — |
| A-O2 | _pending_ (1.99 reported, single run) | _pending_ | _pending_ (≈ 1.69×) | _pending_ (≈ 68.6%) |

**Status:** design specified, **results not yet collected.** No `-O0` data exists at the time of this revision; the table is supplied so that the values can be dropped in without restructuring the document.

### 7.5 Expected patterns to test (hypotheses, not findings)

- **B-O0 ≫ B-O2.** Disabling optimisation should cost the baseline far more than the ratio between them suggests in absolute terms; this is the control that the flags took effect.
- **A-O2 / B-O2 ≈ 1.6–1.8×**, i.e. the §4 pair should reproduce within measurement noise.
- **Direction of the ratio across levels is genuinely open.** Two competing effects: at `-O0` the baseline is slow, so a roughly constant absolute instrumentation cost yields a *smaller* percentage slowdown; but `-O0` also executes more instrumented memory operations (no loop-invariant hoisting, no vectorised coalescing), which pushes the *absolute* cost up. Which effect dominates is what the experiment measures. Report the observed direction; do not assert either in advance.

### 7.6 What the extension does and does not establish

It establishes whether the ASan overhead we measure is sensitive to compiler optimisation on this kernel — useful context for explaining the 4.4-point gap to the paper, since the paper's compiler sat at a very different point on the optimisation curve. It does **not** address the benchmark-suite deviation, which remains structural and is unaffected by any flag-level experiment.

---

## 8. Verification Status

### 8.1 Confirmed (no further action required)

- [x] Benchmark suite: PolyBench/C 4.2.1, GEMM workload.
- [x] Reason for the substitution: SPEC CPU2006 licensing/access restrictions — stated explicitly as a reduced-scale reproduction.
- [x] Platform: Ubuntu on WSL2.
- [x] Compiler: Ubuntu clang 21.1.8.
- [x] Baseline compile command: `clang -O2`.
- [x] ASan compile command: `clang -O2 -fsanitize=address`.
- [x] Reported runtimes: baseline 1.18 s, ASan 1.99 s → ratio ≈ 1.69×, slowdown ≈ 68.6%.
- [x] Claim 2.1 verdict: Supported, with the GEMM-scope qualifier.
- [x] Extension design: `-O0` / `-O2` × baseline / ASan, four cells.

### 8.2 Outstanding (blocks a "final" label)

**Environment (A)**
- [ ] Exact Ubuntu release string.
- [ ] Kernel version and architecture (`uname -a`).
- [ ] CPU model and core count as visible inside WSL2.
- [ ] RAM available to WSL2 (`free -h`), and whether a `.wslconfig` memory cap applies.

**Workload (B)**
- [ ] GEMM matrix dimensions / input size actually used.
- [ ] Confirmation that all four extension cells use identical inputs.

**Configuration and results (D)**
- [ ] Effective ASan heap redzone size on our build (paper: 32 bytes).
- [ ] Stack-unwinding configuration during `malloc`/`free` (paper: disabled).
- [ ] Quarantine size in effect (paper: 0).
- [ ] Provenance of the 1.18 s and 1.99 s figures: single run or aggregate; timer used.
- [ ] Repetition count and aggregation rule for the reported numbers.
- [ ] Raw per-repetition timings for all four extension cells.
- [ ] Peak memory (RSS) measurement, if memory overhead is to be reported (paper: 3.37×).

---

## 9. Update Record

| Date | Update |
|---|---|
| 2026-11-07 | Initial comparison drafted from the paper's Section 4 settings and the group's reported environment. |
| 2026-11-07 | Revision 2: benchmark substitution stated as a settled fact with its licensing rationale; environment fixed as Ubuntu (WSL2) + Ubuntu clang 21.1.8; compile commands fixed at `-O2` and `-O2 -fsanitize=address`; runtime results (1.18 s / 1.99 s, 1.69×, 68.6%) recorded as measurements; Claim 2.1 verdict changed from *Partially Supported* to ***Supported*** with the mandatory GEMM-scope qualifier; §7 extension promoted from proposal to a specified 2 × 2 experiment with procedure and results table. |

---

## 10. Reference

Serebryany, K., Bruening, D., Potapenko, A., & Vyukov, D. (2012). *AddressSanitizer: A Fast Address Sanity Checker*. Proceedings of the 2012 USENIX Annual Technical Conference (USENIX ATC '12).

PolyBench/C 4.2.1 — Pouchet, L.-N. *PolyBench: The Polyhedral Benchmark Suite* (version 4.2.1), GEMM kernel.


## Compiler Optimization vs. Bug Detection:
During our functional tests, we discovered that compiling with -O1 or higher on Apple Clang 14 aggressively eliminated our out-of-bounds and double-free test cases via dead code elimination (DCE). This aligns with the conflict between compiler optimizations and ASan instrumentation described in the original paper (Section 3.6.1). To ensure bugs are faithfully executed, we compiled our functional test cases at -O0. However, our performance benchmark (gemm.c) remains at -O2 to match the paper's evaluation settings, demonstrating a necessary separation between functional validation and performance measurement.