import matplotlib.pyplot as plt
import numpy as np
import re
import os

MD_PATH = "results/extension_result.md"
FIG_DIR = "figure/extension"
os.makedirs(FIG_DIR, exist_ok=True)


def parse_md_table(md_text):
    match = re.search(r"## Summary Table\s*\n((?:\|.*\|\n)+)", md_text, re.DOTALL)
    if not match:
        raise RuntimeError("Cannot find ## Summary Table")
    table_block = match.group(1)
    lines = [l.strip() for l in table_block.splitlines() if l.strip()]

    header = None
    data_rows = []
    for idx, line in enumerate(lines):
        cells = [c.strip() for c in line.split("|")[1:-1]]
        if idx == 0:
            header = cells
            continue
        if all(s.startswith("-") for s in cells):
            continue
        data_rows.append(cells)

    col_idx = {name: i for i, name in enumerate(header)}

    label_list = []
    threads_arr = []
    mean_s_arr = []
    speedup_arr = []
    slowdown_arr = []
    mem_arr = []
    mem_ratio_arr = []

    for row in data_rows:
        label = row[col_idx["label"]]
        try:
            th = int(row[col_idx["threads"]])
            mean_s = float(row[col_idx["mean_s"]])
            sp = float(row[col_idx["speedup"]])

            mem_str = row[col_idx["peak_mem_mb"]]
            mem = np.nan if mem_str == "NA" else float(mem_str)

            sd_str = row[col_idx["slowdown"]]
            sd = np.nan if sd_str == "-" else float(sd_str.replace("x", ""))

            mr_str = row[col_idx["memory_ratio"]]
            mr = np.nan if mr_str == "NA" else float(mr_str)

        except ValueError:
            continue

        label_list.append(label)
        threads_arr.append(th)
        mean_s_arr.append(mean_s)
        speedup_arr.append(sp)
        slowdown_arr.append(sd)
        mem_arr.append(mem)
        mem_ratio_arr.append(mr)

    label_arr = np.array(label_list, dtype=object)
    threads = np.array(threads_arr)
    mean_s = np.array(mean_s_arr)
    speedup = np.array(speedup_arr)
    slowdown = np.array(slowdown_arr)
    peak_mem = np.array(mem_arr)
    memory_ratio = np.array(mem_ratio_arr)

    mask_serial = label_arr == "serial"
    mask_serial_asan = label_arr == "serial_asan"
    mask_pt = label_arr == "pthread"
    mask_pt_asan = label_arr == "pthread_asan"

    return (
        threads, label_arr, mean_s, speedup, slowdown, peak_mem, memory_ratio,
        mask_serial, mask_serial_asan, mask_pt, mask_pt_asan
    )


def main():
    with open(MD_PATH, "r", encoding="utf-8") as f:
        content = f.read()

    (
        threads, label_arr, mean_s, speedup, slowdown, peak_mem, memory_ratio,
        mask_serial, mask_serial_asan, mask_pt, mask_pt_asan
    ) = parse_md_table(content)

    t_ser = threads[mask_serial]
    m_ser = mean_s[mask_serial]

    t_ser_asan = threads[mask_serial_asan]
    m_ser_asan = mean_s[mask_serial_asan]

    t_pt = threads[mask_pt]
    m_pt = mean_s[mask_pt]
    sp_pt = speedup[mask_pt]
    mem_pt = peak_mem[mask_pt]

    t_pt_asan = threads[mask_pt_asan]
    m_pt_asan = mean_s[mask_pt_asan]
    sp_pt_asan = speedup[mask_pt_asan]
    sd_pt_asan = slowdown[mask_pt_asan]
    mr_pt_asan = memory_ratio[mask_pt_asan]
    mem_pt_asan = peak_mem[mask_pt_asan]

    plt.rcParams["font.size"] = 11
    plt.rcParams["figure.dpi"] = 150

    # 1. mean_s 
    fig1, ax1 = plt.subplots(figsize=(7, 4.4))
    ax1.plot(t_pt, m_pt, marker="o", linestyle="-", color="#1f77b4", label="pthread")
    ax1.plot(t_pt_asan, m_pt_asan, marker="s", linestyle="-", color="#ff7f0e", label="pthread_asan")
    ax1.set_xlabel("Threads")
    ax1.set_ylabel("Mean Execution Time (s)")
    ax1.set_title("Mean Time Comparison")
    all_ticks = np.sort(np.unique(np.concatenate([t_pt, t_pt_asan])))
    ax1.set_xticks(all_ticks)
    ax1.legend()
    ax1.grid(alpha=0.3)
    fig1.tight_layout()
    fig1.savefig(os.path.join(FIG_DIR, "mean_time_plot.png"))
    plt.close(fig1)

    # 2. speedup 
    fig2, ax2 = plt.subplots(figsize=(7, 4.4))
    ax2.plot(t_pt, sp_pt, marker="o", color="#1f77b4", label="pthread")
    ax2.plot(t_pt_asan, sp_pt_asan, marker="s", color="#ff7f0e", label="pthread_asan")
    ax2.set_xlabel("Threads")
    ax2.set_ylabel("Speedup")
    ax2.set_title("Speedup Comparison")
    ax2.set_xticks(np.sort(np.unique(np.concatenate([t_pt, t_pt_asan]))))
    ax2.legend()
    ax2.grid(alpha=0.3)
    fig2.tight_layout()
    fig2.savefig(os.path.join(FIG_DIR, "speedup_plot.png"))
    plt.close(fig2)

    # 3. slowdown 
    fig3, ax3 = plt.subplots(figsize=(7, 4.4))
    ax3.plot(t_ser_asan, m_ser_asan, marker="o", linestyle="-", color="#fd0000", label="serial_asan")
    ax3.plot(t_pt_asan, sd_pt_asan, marker="s", color="#ff7f0e",label="pthread_asan")
    ax3.set_xlabel("Threads")
    ax3.set_ylabel("Slowdown Ratio (ASan / Baseline)")
    ax3.set_title("Pthread_asan Slowdown Ratio")
    ax3.set_xticks(t_pt_asan)
    ax3.margins(y=0.2)
    ax3.legend()
    ax3.grid(alpha=0.3)
    fig3.tight_layout()
    fig3.savefig(os.path.join(FIG_DIR, "slowdown_plot.png"))
    plt.close(fig3)

    # 4. memory_ratio
    fig4, ax4 = plt.subplots(figsize=(7, 4.4))
    ax4.plot(t_pt_asan, mr_pt_asan, marker="s", color="#ff7f0e")
    ax4.set_xlabel("Threads")
    ax4.set_ylabel("Memory Ratio (ASan / Baseline)")
    ax4.set_title("Pthread_asan Memory Ratio")
    ax4.set_xticks(t_pt_asan)
    ax4.margins(y=5.0)
    ax4.grid(alpha=0.3)
    fig4.tight_layout()
    fig4.savefig(os.path.join(FIG_DIR, "memory_ratio_plot.png"))
    plt.close(fig4)

    # 5. peak memory 
    fig5, ax5 = plt.subplots(figsize=(7, 4.4))
    ax5.plot(t_pt, mem_pt, marker="o", linestyle="-", color="#1f77b4", label="pthread")
    ax5.plot(t_pt_asan, mem_pt_asan, marker="s", linestyle="-", color="#ff7f0e", label="pthread_asan")
    ax5.set_xlabel("Threads")
    ax5.set_ylabel("Peak Memory (MB)")
    ax5.set_title("Peak Memory Comparison")
    ax5.set_xticks(np.sort(np.unique(np.concatenate([t_pt, t_pt_asan]))))
    ax5.legend()
    ax5.grid(alpha=0.3)
    fig5.tight_layout()
    fig5.savefig(os.path.join(FIG_DIR, "peak_memory_plot.png"))
    plt.close(fig5)


if __name__ == "__main__":
    main()
