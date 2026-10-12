#!/usr/bin/env bash
# The comm-cols case lost a line on 25.10. Repeat it 20 times per release to see
# whether that is a one-off or a pattern. Output: results/comm-repeat.txt
set -uo pipefail
cd "$(dirname "$0")/.."
for v in 25.10 26.04 26.10; do
  R=rootfs/$v
  sudo mount --bind /dev "$R/dev"; sudo mount -t proc proc "$R/proc"
  sudo mkdir -p "$R/t"
  printf 'apple\napple\nbanana\napple\ncherry\ncherry\n' | sudo tee "$R/t/dup.txt" >/dev/null
  n=$(sudo chroot "$R" /usr/bin/env -i PATH=/usr/bin:/bin LC_ALL=C.UTF-8 /bin/bash -c '
    cd /t; missing=0
    for i in $(seq 1 20); do
      comm <(sort dup.txt | uniq) <(printf "apple\ndate\n") | grep -q cherry || missing=$((missing+1))
    done; echo $missing')
  echo "$v $(sudo chroot "$R" comm --version | head -1): cherry missing in $n of 20 runs"
  sudo rm -rf "$R/t"; sudo umount "$R/proc" "$R/dev"
done | tee results/comm-repeat.txt
