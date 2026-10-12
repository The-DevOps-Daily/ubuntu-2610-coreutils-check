#!/usr/bin/env bash
# Run every case in cases.tsv in four setups and keep stdout, stderr and the
# exit code of each run under results/<setup>/<case>.{out,err,rc}.
#   gnu-24.04     Ubuntu 24.04, GNU coreutils 9.4
#   mixed-25.10   Ubuntu 25.10, uutils 0.2.2 with GNU cp/mv/rm/chmod/chown/df/true
#   mixed-26.04   Ubuntu 26.04.1 LTS, uutils 0.8.0 with GNU cp/mv/rm/df/true
#   uutils-26.10  Ubuntu 26.10 beta, uutils 0.12.0 for every tool
#   gnu-26.10     Ubuntu 26.10 beta, the same OS with GNU 9.10 first in PATH
set -euo pipefail
cd "$(dirname "$0")/.."
ROOT=$PWD
SETUPS=("gnu-24.04 24.04 /usr/bin:/bin" "mixed-25.10 25.10 /usr/bin:/bin" "mixed-26.04 26.04 /usr/bin:/bin" "uutils-26.10 26.10 /usr/bin:/bin" "gnu-26.10 26.10 /opt/gnushim:/usr/bin:/bin")

mounts() { # up|down rootfs
  local r="$ROOT/rootfs/$2"
  if [ "$1" = up ]; then
    sudo mount --bind /dev "$r/dev" && sudo mount -o remount,bind,ro "$r/dev"
    sudo mount -t proc proc "$r/proc"
  else
    sudo umount "$r/proc" "$r/dev" 2>/dev/null || true
  fi
}
trap 'for v in 24.04 25.10 26.04 26.10; do mounts down $v; done' EXIT

FIX=$(mktemp -d); scripts/fixtures.sh "$FIX/work" >/dev/null
for v in 24.04 25.10 26.04 26.10; do mounts up $v; done

for s in "${SETUPS[@]}"; do
  read -r name ver path <<<"$s"
  out="results/$name"; rm -rf "$out"; mkdir -p "$out"
  while IFS=$'\t' read -r id cmd; do
    [[ -z "$id" || "$id" == \#* ]] && continue
    sudo rm -rf "rootfs/$ver/work"; sudo cp -a "$FIX/work" "rootfs/$ver/work"
    set +e
    sudo chroot "rootfs/$ver" /usr/bin/env -i PATH="$path" LC_ALL=C.UTF-8 TZ=UTC HOME=/root \
      /bin/bash -c "cd /work && $cmd" >"$out/$id.out" 2>"$out/$id.err" </dev/null
    echo $? >"$out/$id.rc"
    set -e
  done < cases.tsv
  echo "$name: $(ls "$out"/*.rc | wc -l) cases"
done
sudo rm -rf "$FIX" rootfs/*/work
