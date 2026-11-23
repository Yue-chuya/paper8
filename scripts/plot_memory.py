import matplotlib.pyplot as plt
import numpy as np
import re
import os

MD_DEFAULT = "results/benchmark_result.md"
MD_PAPER = "results/paper_params_result.md"
OUTPUT_IMG = "figure/memory_overhead.png"

def parse_md(filepath):
    with open(filepath, 'r') as f:
        text = f.read()
  
    baseline_match = re.search(r"- Baseline Peak Mem \(MB\):\s+([\d\. ]+)", text)
    asan_match = re.search(r"- ASan Peak Mem \(MB\):\s+([\d\. ]+)", text)
    
    b_mems = [float(x) for x in baseline_match.group(1).split()]
    a_mems = [float(x) for x in asan_match.group(1).split()]
    return b_mems, a_mems

def calc_mem_ratio(b_mems, a_mems):
    b_mean = np.mean(b_mems)
    a_mean = np.mean(a_mems)
    ratio = a_mean / b_mean
    return ratio

b_def, a_def = parse_md(MD_DEFAULT)
b_pap, a_pap = parse_md(MD_PAPER)
ratio_def = calc_mem_ratio(b_def, a_def)
ratio_pap = calc_mem_ratio(b_pap, a_pap)

# draw bar chart
plt.style.use('default')
fig, ax = plt.subplots(figsize=(7, 5))
labels = ['Our Benchmark(default)', 'Paper Params']
ratios = [ratio_def, ratio_pap]
colors = ["#4ea0db", "#ff9100"] 
bars = ax.bar(labels, ratios, color=colors, alpha=0.9, width=0.35)

# original paper value
paper_val = 3.37
ax.axhline(y=paper_val, color='#d62728', linestyle='--', linewidth=2, label=f"Original paper ({paper_val}x)")

for i, v in enumerate(ratios):
    ax.text(i, v + 0.1, f'{v:.2f}x', ha='center', fontweight='bold', fontsize=12, color='black')

ax.set_ylabel('Memory Ratio (x)', fontsize=13)
ax.set_title('Memory Overhead: Our Benchmark vs. Paper Parameters', fontsize=15,fontweight='bold', pad=15)
ax.set_ylim(0, 4.0)
ax.legend(loc='upper right', fontsize=11, framealpha=1.0)
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)
ax.yaxis.grid(True, linestyle='--', alpha=0.6)
ax.set_axisbelow(True)

plt.tight_layout()
os.makedirs(os.path.dirname(OUTPUT_IMG), exist_ok=True)
plt.savefig(OUTPUT_IMG, dpi=300, bbox_inches='tight')
