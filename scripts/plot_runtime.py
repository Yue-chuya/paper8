import matplotlib.pyplot as plt
import numpy as np
import re
import os

MD_DEFAULT = "results/benchmark_result.md"
MD_PAPER = "results/paper_params_result.md"
OUTPUT_IMG = "figure/runtime_overhead.png"

def parse_md(filepath):
    with open(filepath, 'r') as f:
        text = f.read()

    baseline_match = re.search(r"- Baseline(?: Times)?:\s+([\d\. ]+)", text)
    asan_match = re.search(r"- ASan(?: Times)?:\s+([\d\. ]+)", text)
    b_times = [float(x) for x in baseline_match.group(1).split()]
    a_times = [float(x) for x in asan_match.group(1).split()]
    return b_times, a_times

def calc_slowdown(b_times, a_times):
    b_mean = np.mean(b_times)
    a_mean = np.mean(a_times)
    slowdown = (a_mean / b_mean - 1) * 100
    return slowdown

b_def, a_def = parse_md(MD_DEFAULT)
b_pap, a_pap = parse_md(MD_PAPER)
slow_def = calc_slowdown(b_def, a_def)
slow_pap = calc_slowdown(b_pap, a_pap)

#draw bar chart
plt.style.use('default')
fig, ax = plt.subplots(figsize=(7, 5))
labels = ['Our Benchmark(default)', 'Paper Params']
slowdowns = [slow_def, slow_pap]
colors = ["#4ea0db", "#ff9100"] 
bars = ax.bar(labels, slowdowns, color=colors, alpha=0.9, width=0.35)

# original paper value
paper_val = 73.0
ax.axhline(y=paper_val, color='#d62728', linestyle='--', linewidth=2, label=f"Original paper ({paper_val}%)")

for i, v in enumerate(slowdowns):
    ax.text(i, v + 1.5, f'{v:.2f}%', ha='center', fontweight='bold', fontsize=12, color='black')

ax.set_ylabel('Slowdown (%)', fontsize=13)
ax.set_title('Runtime Overhead: Our Benchmark vs. Paper Parameters', fontsize=15, fontweight='bold', pad=15)
ax.set_ylim(0, 85) 
ax.legend(loc='upper right', fontsize=11, framealpha=1.0)
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)
ax.yaxis.grid(True, linestyle='--', alpha=0.6)
ax.set_axisbelow(True)

plt.tight_layout()
os.makedirs(os.path.dirname(OUTPUT_IMG), exist_ok=True)
plt.savefig(OUTPUT_IMG, dpi=300, bbox_inches='tight')
