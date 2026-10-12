#!/usr/bin/env bash
# Time common workloads with GNU 9.10 and uutils 0.12.0 inside the same
# Ubuntu 26.10 rootfs. Each workload runs 7 times per implementation, the two
# implementations alternate, and results/bench.tsv keeps every run. Run 1 is
# a warm-up and 06-bench-summary.py leaves it out of the medians.
set -euo pipefail
cd "$(dirname "$0")/.."
R=rootfs/26.10
RUNS=${RUNS:-7}
sudo mkdir -p "$R/bench"
# Real /dev and /proc inside the chroot. Without them ">/dev/null" creates a
# regular file and every run writes its output to disk (our first run did).
sudo mount --bind /dev "$R/dev" && sudo mount -o remount,bind,ro "$R/dev"
sudo mount -t proc proc "$R/proc"
trap 'sudo umount "$R/proc" "$R/dev" 2>/dev/null' EXIT
[ -f "$R/bench/big.bin" ] || python3 - "$R" <<'PY'
import random, sys, os, subprocess
r = sys.argv[1]; random.seed(42)
words = [''.join(random.choice('abcdefghijklmnopqrstuvwxyz') for _ in range(random.randint(3, 10))) for _ in range(50000)]
tmp = "/tmp/bench-gen"; os.makedirs(tmp, exist_ok=True)
with open(f"{tmp}/nums.txt", "w") as f:
    f.writelines(f"{random.randint(-10**9, 10**9)}\n" for _ in range(1_000_000))
with open(f"{tmp}/text.txt", "w") as f:
    f.writelines(f"{random.choice(words)} {random.choice(words)} {random.randint(0, 999)}\n" for _ in range(1_000_000))
with open(f"{tmp}/big.bin", "wb") as f:
    f.write(random.Random(7).randbytes(100 * 1024 * 1024))
os.makedirs(f"{tmp}/tree", exist_ok=True)
for i in range(5000):
    d = f"{tmp}/tree/d{i % 50}"; os.makedirs(d, exist_ok=True)
    with open(f"{d}/f{i}.txt", "w") as f: f.write(words[i] * 20)
subprocess.run(["sudo", "cp", "-a", f"{tmp}/.", f"{r}/bench/"], check=True)
subprocess.run(["rm", "-rf", tmp], check=True)
PY

WORKLOADS=(
  "sort-numeric|sort -n nums.txt >/dev/null"
  "sort-text|sort text.txt >/dev/null"
  "sort-unique|sort -u text.txt >/dev/null"
  "sort-key|sort -k3,3n -k1,1 text.txt >/dev/null"
  "uniq-count|sort text.txt | uniq -c >/dev/null"
  "wc-lines|wc -l text.txt >/dev/null"
  "wc-words|wc -w text.txt >/dev/null"
  "cut-field|cut -d' ' -f2 text.txt >/dev/null"
  "tr-upper|tr a-z A-Z <text.txt >/dev/null"
  "sha256sum|sha256sum big.bin >/dev/null"
  "md5sum|md5sum big.bin >/dev/null"
  "base64|base64 big.bin >/dev/null"
  "cp-tree|cp -r tree tree-copy && rm -rf tree-copy"
  "ls-recursive|ls -lR tree >/dev/null"
  "du-tree|du -s tree >/dev/null"
)
out=${OUT:-results/bench.tsv}
echo -e "workload\timpl\trun\tseconds" > "$out"
for w in "${WORKLOADS[@]}"; do
  name=${w%%|*}; cmd=${w#*|}
  [[ -n "${ONLY:-}" && ! "$name" =~ $ONLY ]] && continue
  case $cmd in
    *nums.txt*) warm="cat nums.txt" ;;
    *text.txt*) warm="cat text.txt" ;;
    *big.bin*)  warm="cat big.bin" ;;
    *)          warm="find tree -type f -exec cat {} +" ;;
  esac
  for run in $(seq 1 "$RUNS"); do
    for impl in gnu uutils; do
      path=/usr/bin:/bin; [ "$impl" = gnu ] && path=/opt/gnushim:/usr/bin:/bin
      # Read the workload's input first so the timed run reads from page cache.
      sudo chroot "$R" /bin/bash -c "cd /bench && $warm >/dev/null"
      t=$(sudo chroot "$R" /usr/bin/env -i PATH="$path" LC_ALL=C.UTF-8 /bin/bash -c "cd /bench && TIMEFORMAT=%R; { time ( $cmd ) ; } 2>&1 >/dev/null | tail -1")
      echo -e "$name\t$impl\t$run\t$t" >> "$out"
    done
  done
  echo "$name done"
done
