#!/usr/bin/env bash
# Record what each base image ships: coreutils packages and versions, where the
# common tools link to, and how many gnu* binaries exist. Run after 02-extract.sh.
set -uo pipefail
cd "$(dirname "$0")/.."
out=results/inventory.txt; : > "$out"
( cd downloads && sha256sum *.tar.gz ) >> "$out"
for v in 24.04 25.10 26.04 26.10; do
  {
    echo "== $v"
    sudo chroot "rootfs/$v" /bin/bash -c '
      . /etc/os-release; echo "$PRETTY_NAME"
      dpkg-query -W -f="\${Package} \${Version}\n" coreutils rust-coreutils gnu-coreutils coreutils-from-uutils coreutils-from-gnu 2>/dev/null
      for t in cp mv rm chmod chown df true ls sort date cut timeout base64 comm; do echo "$t -> $(readlink -f /usr/bin/$t)"; done
      echo "gnu* binaries in /usr/bin: $(ls /usr/bin/gnu* 2>/dev/null | wc -l)"'
  } >> "$out" 2>&1
done
cat "$out"
