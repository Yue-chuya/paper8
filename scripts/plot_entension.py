import matplotlib.pyplot as plt
import numpy as np
import re
import os

MD_FILE = "results/extension_result.md"
OUTPUT_IMG = "figure/extension_redzone.png"

def parse_md(filepath):
    with open(filepath, 'r') as f:
        text = f.read()
    
    b_time_match = re.search(r"- Baseline Times:\s+([\d\. ]+)", text)
    a128_time_match = re.search(r"- ASan\(128B\) Times:\s+([\d\. ]+)", text)
    a32_time_match = re.search(r"- ASan\(32B\) Times:\s+([\d\. ]+)", text)
    
    b_mem_match = re.search(r"- Baseline Peak Mem:\s+([\d\. ]+)", text)
    a128_mem_match = re.search(r"- ASan\(128B\) Peak Mem:\s+([\d\. ]+)", text)
    a32_mem_match = re.search(r"- ASan\(32B\) Peak Mem:\s+([\d\. ]+)", text)

    def to_floats(match_obj):
        return [float(x) for x in match_obj.group(1).split()]

    return (to_floats(b_time_match), to_floats(a128_time_match), to_floats(a32_time_match),
            to_floats(b_mem_match), to_floats(a128_mem_match), to_floats(a32_mem_match))

b_t, a128_t, a32_t, b_m, a128_m, a32_m = parse_md(MD_FILE)
slow_32 = (np.mean(a32_t) / np.mean(b_t) - 1) * 100
slow_128 = (np.mean(a128_t) / np.mean(b_t) - 1) * 100

mem_32 = np.mean(a32_m) / np.mean(b_m)
mem_128 = np.mean(a128_m) / np.mean(b_m)

# draw bar chart
plt.style.use('default')
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
labels = ['32B', '128B']
x_pos = np.arange(len(labels))
colors = ["#1f9bb4", "#ffcc00"] 

# Runtime Impact
bars1 = ax1.bar(x_pos, [slow_32, slow_128], color=colors, width=0.35)
ax1.set_ylabel('Slowdown (%)', fontsize=13)
ax1.set_title('Runtime Impact', fontsize=14,fontweight='bold')
ax1.set_xticks(x_pos)
ax1.set_xticklabels(labels, fontsize=11)
ax1.set_ylim(0, max(slow_32, slow_128) + 10)
ax1.spines['top'].set_visible(False)
ax1.spines['right'].set_visible(False)
ax1.yaxis.grid(True, linestyle='--', alpha=0.6)
ax1.set_axisbelow(True)
for i, v in enumerate([slow_32, slow_128]):
    ax1.text(i, v + 0.5, f'{v:.2f}%', ha='center', fontweight='bold', fontsize=12)

# Memory Impact
bars2 = ax2.bar(x_pos, [mem_32, mem_128], color=colors, width=0.35)
ax2.set_ylabel('Memory Ratio (x)', fontsize=13)
ax2.set_title('Memory Impact', fontsize=14,fontweight='bold')
ax2.set_xticks(x_pos)
ax2.set_xticklabels(labels, fontsize=11)
ax2.set_ylim(0, max(mem_32, mem_128) + 5)
ax2.spines['top'].set_visible(False)
ax2.spines['right'].set_visible(False)
ax2.yaxis.grid(True, linestyle='--', alpha=0.6)
ax2.set_axisbelow(True)
for i, v in enumerate([mem_32, mem_128]):
    ax2.text(i, v + 0.5, f'{v:.2f}x', ha='center', fontweight='bold', fontsize=12)

plt.tight_layout()
os.makedirs(os.path.dirname(OUTPUT_IMG), exist_ok=True)
plt.savefig(OUTPUT_IMG, dpi=300, bbox_inches='tight')
