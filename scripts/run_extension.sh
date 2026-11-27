#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."
WORK_DIR="experiments/workload"
SERIAL_SRC="$WORK_DIR/gemm.c"
PTHREAD_SRC="$WORK_DIR/gemm_thread.c"
RESULT_DIR="results"
mkdir -p "$WORK_DIR" "$RESULT_DIR"

CC="${CC:-clang}"
REPS="${REPS:-3}"
THREADS="${THREADS:-1 2 4 8}"
BASE_OPT="${BASE_OPT:--O2}"
ASAN_OPT_FLAGS="${ASAN_OPT_FLAGS:--fsanitize=address -fno-omit-frame-pointer}"
RESULT="$RESULT_DIR/extension_result.md"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
BINDIR="$WORK_DIR"
ERRF="$WORK/stderr"
mkdir -p "$BINDIR"

OS_TYPE=$(uname)
if [ "$OS_TYPE" == "Darwin" ]; then
    TIME_CMD="/usr/bin/time -l"
    MEM_GREP="maximum resident set size"
    MEM_AWK="{print \$1}" 
else
    TIME_CMD="/usr/bin/time -v"
    MEM_GREP="Maximum resident set size"
    MEM_AWK="{print \$NF}" 
fi

echo "----- Waiting for the results -----"

# compile serial and pthread versions
if [[ -f "$SERIAL_SRC" ]]; then
  "$CC" $BASE_OPT -pthread "$SERIAL_SRC" -o "$BINDIR/serial"
  "$CC" $BASE_OPT -pthread $ASAN_OPT_FLAGS "$SERIAL_SRC" -o "$BINDIR/serial_asan"
else
  echo "warning: $SERIAL_SRC not exists, skipping serial compilation"
fi
[[ -f "$PTHREAD_SRC" ]] || { echo "error: $PTHREAD_SRC not exists"; exit 1; }
"$CC" $BASE_OPT -pthread "$PTHREAD_SRC" -o "$BINDIR/demo_baseline_thread"
"$CC" $BASE_OPT -pthread $ASAN_OPT_FLAGS "$PTHREAD_SRC" -o "$BINDIR/demo_asan_thread"

# capture data
run_one() {
  local bin="$1" th="$2" label="$3" rep="$4" out secs rss mem_mb
  if ! out=$(GEMM_REPORT_MEM=1 "$bin" "$th" 2>"$ERRF"); then
    echo "run failed: label=$label threads=$th rep=$rep"
    printf '%s,%s,%s,NA,NA\n' "$label" "$th" "$rep"
    return 0
  fi

  secs=$(printf '%s\n' "$out" | grep -Eo '[0-9]+(\.[0-9]+)?' | head -n1 || true)
  rss=$(grep -Eo 'maxrss_kb=[0-9]+' "$ERRF" 2>/dev/null | head -n1 | cut -d= -f2 || true)
  if [[ -n "$rss" ]]; then
    case "$(uname -s)" in
      Darwin|*BSD) mem_mb=$(awk -v r="$rss" 'BEGIN { printf "%.2f", r / 1048576 }') ;;
      *)           mem_mb=$(awk -v r="$rss" 'BEGIN { printf "%.2f", r / 1024 }') ;;
    esac
  fi
  printf '%s,%s,%s,%s,%s\n' "$label" "$th" "$rep" "${secs:-NA}" "${mem_mb:-NA}"
}

RAW_BLOCK=$(
{
echo "label,threads,rep,time_s,peak_mem_mb"
for rep in $(seq 1 "$REPS"); do
  [[ -x "$BINDIR/serial" ]]      && run_one "$BINDIR/serial"      1 serial      "$rep"
  [[ -x "$BINDIR/serial_asan" ]] && run_one "$BINDIR/serial_asan" 1 serial_asan "$rep"
  for th in $THREADS; do
    [[ -x "$BINDIR/demo_baseline_thread" ]]      && run_one "$BINDIR/demo_baseline_thread"      "$th" pthread      "$rep"
    [[ -x "$BINDIR/demo_asan_thread" ]] && run_one "$BINDIR/demo_asan_thread" "$th" pthread_asan "$rep"
  done
done
}
)

SUMMARY_TEXT=$(
echo "$RAW_BLOCK" | awk -F, '
NR == 1 { next }
{
    if ($4 == "NA") next
    key = $1 "|" $2
    if (!(key in n)) { order[++m] = key }
    n[key]++
    t[key, n[key]] = $4 + 0
    if ($5 ~ /^[0-9]+(\.[0-9]+)?$/ && (!(key in mem) || $5 + 0 > mem[key])) {
        mem[key] = $5 + 0
    }
}
END {
    for (i = 1; i <= m; i++) {
        key = order[i]; cnt = n[key]
        s = 0
        for (a = 1; a <= cnt; a++) {
            v[a] = t[key, a]
            s += v[a]
        }
        for (a = 2; a <= cnt; a++) {
            x = v[a]; b = a - 1
            while (b >= 1 && v[b] > x) { v[b + 1] = v[b]; b-- }
            v[b + 1] = x
        }
        mins[key] = v[1]
        means[key] = s / cnt
        sq = 0
        for (a = 1; a <= cnt; a++) {
            d = v[a] - means[key]
            sq += d * d
        }
        stds[key] = (cnt > 1) ? sqrt(sq / (cnt - 1)) : 0

        split(key, kk, "|")
        lbl = kk[1]; th = kk[2]
        if(lbl=="pthread" && mem[key]!=""){
            base_mem[th]=mem[key]
        }
    }
    bn = means["serial|1"];      if (bn == "") bn = means["pthread|1"]
    ba = means["serial_asan|1"]; if (ba == "") ba = means["pthread_asan|1"]
    print "label,threads,min_s,mean_s,std_s,peak_mem_mb,memory_ratio,speedup,slowdown"
    for (i = 1; i <= m; i++) {
        key = order[i]; split(key, kk, "\\|")
        lbl = kk[1]; th = kk[2]
        is_asan = (lbl ~ /asan/)
        base = is_asan ? ba : bn
        sp = (base > 0 && means[key] > 0) ? base / means[key] : 0
        sd = "-"
        mr = "NA"
        if (is_asan) {
            base_lbl = lbl
            sub(/_asan$/, "", base_lbl)
            bkey = base_lbl "|" th
            if ((bkey in means) && means[bkey] > 0) {
                sd = sprintf("%.2fx", means[key] / means[bkey])
            }
       
            if( th in base_mem && mem[key]!="" ){
                mr = sprintf("%.2f", mem[key] / base_mem[th])
            }
        }
        printf "%s,%s,%.6f,%.6f,%.6f,%s,%s,%.2f,%s\n",
               lbl, th, mins[key], means[key], stds[key],
               (key in mem) ? sprintf("%.2f", mem[key]) : "NA",
               mr,
               sp,
               sd
    }
}'
)

SUMMARY_MD_TABLE=$(awk -F',' '
BEGIN { OFS=" | " }
NR == 1 {
    printf "| "
    for(i=1; i<=NF; i++){
        if(i>1) printf " | "
        printf "%s", $i
    }
    printf " |\n"
    printf "| ---"
    for(i=2; i<=NF; i++){
        printf " | ---"
    }
    printf " |\n"
    next
}
{
    printf "| "
    for(i=1; i<=NF; i++){
        if(i>1) printf " | "
        printf "%s", $i
    }
    printf " |\n"
}
' < <(printf "%s\n" "$SUMMARY_TEXT"))

STATS_BLOCK=$(echo "$RAW_BLOCK" | awk -F, '
NR == 1 { next }
{
    lbl=$1; th=$2; ts=$4; mem=$5
    if (ts == "NA") next
    k=lbl"|"th
    time_arr[k] = time_arr[k] " " ts
    mem_arr[k] = mem_arr[k] " " mem
}
END {
    split("'"$THREADS"'", thr_list, " ")
    len = length(thr_list)
    for (ti=1; ti<=len; ti++) {
        th = thr_list[ti]
        base_key = "pthread|" th
        asan_key = "pthread_asan|" th
        if (!(base_key in time_arr)) continue
        n=split(time_arr[base_key], bt, " "); sum_t=0; sumt2=0; maxmem=0
        for(i=1;i<=n;i++){v=bt[i]+0; sum_t+=v; sumt2+=v*v;}
        mean_t = sum_t / n
        std_t = (n>1) ? sqrt((sumt2 - sum_t*sum_t/n)/(n-1)) : 0
        split(mem_arr[base_key], bm, " "); sum_m=0
        for(i=1;i<=n;i++){v=bm[i]+0; sum_m+=v; if(v>maxmem) maxmem=v;}
        mean_m = sum_m / n
        mean_ta = 0; std_ta =0; mean_ma=0; maxmem_a=0
        if (asan_key in time_arr) {
            split(time_arr[asan_key], at, " "); sum_ta=0; sumt2a=0
            for(i=1;i<=n;i++){v=at[i]+0; sum_ta+=v; sumt2a+=v*v;}
            mean_ta = sum_ta / n
            std_ta = (n>1) ? sqrt((sumt2a - sum_ta*sum_ta/n)/(n-1)) : 0
            split(mem_arr[asan_key], am, " "); sum_ma=0
            for(i=1;i<=n;i++){v=am[i]+0; sum_ma+=v; if(v>maxmem_a) maxmem_a=v;}
            mean_ma = sum_ma / n
        }
        slowdown = (mean_t>0 && mean_ta>0) ? mean_ta / mean_t : 0
        mem_ratio = (mean_m>0 && mean_ma>0) ? mean_ma / mean_m : 0
        print "### Threads = " th
        print "#### Raw Data"
        print "- Baseline:           " time_arr[base_key]
        print "- ASan:               " time_arr[asan_key]
        print "- Baseline Peak Mem (MB):" mem_arr[base_key]
        print "- ASan Peak Mem (MB):    " mem_arr[asan_key]
        print ""
        print "#### Statistics"
        printf "- Baseline Mean: %.4f s, Std: %.4f\n", mean_t, std_t
        printf "- ASan Mean: %.4f s, Std: %.4f\n", mean_ta, std_ta
        printf "- Ratio: %.2fx\n", slowdown
        printf "- Slowdown: %.2f%%\n", (slowdown - 1)*100
        printf "- Baseline Peak Mem Mean: %.2f MB\n", mean_m
        printf "- ASan Peak Mem Mean: %.2f MB\n", mean_ma
        printf "- Memory Ratio: %.2fx\n", mem_ratio
        print ""
    }
}')

MAX_TH="$(printf '%s\n' $THREADS | sort -n | tail -n1)"
C1="NA"; CN="NA"
if [[ -x "$BINDIR/demo_baseline_thread" ]]; then
  C1=$(GEMM_VERIFY=1 "$BINDIR/demo_baseline_thread" 1         2>&1 >/dev/null | grep -o 'checksum=.*' | head -n1 || true)
  CN=$(GEMM_VERIFY=1 "$BINDIR/demo_baseline_thread" "$MAX_TH" 2>&1 >/dev/null | grep -o 'checksum=.*' | head -n1 || true)
fi

val_c1="${C1#*=}"
val_c1="${val_c1:-NA}"
val_cn="${CN#*=}"
val_cn="${val_cn:-NA}"

# extension_result.md 
{
  echo "# Extension result"
  echo "$STATS_BLOCK"
  echo "## Verification"
  echo "| Item | Value |"
  echo "| --- | --- |"
  echo "| checksum pthread (1 thread) | ${val_c1} |"
  echo "| checksum pthread (${MAX_TH} threads) | ${val_cn} |"
  if [[ "$C1" != "NA" && "$C1" == "$CN" ]]; then
    echo "| checksum_match | yes |"
  else
    echo "| checksum_match | no |"
  fi
  echo "## Summary Table"
  echo "$SUMMARY_MD_TABLE"
} > "$RESULT"

if command -v column >/dev/null 2>&1; then
    echo "$SUMMARY_TEXT" | column -s, -t
else
    echo "$SUMMARY_TEXT"
fi

echo "----------------------------------------"
echo "Extension completed."