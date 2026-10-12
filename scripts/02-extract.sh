#!/usr/bin/env bash
# Unpack each image into rootfs/<version> and add a shim dir in 26.10 whose
# symlinks point every coreutils name at the gnu-prefixed GNU binary, so the
# same OS can run each case with GNU and with uutils.
set -euo pipefail
cd "$(dirname "$0")/.."
declare -A IMG=([24.04]=ubuntu-base-24.04.5 [25.10]=ubuntu-base-25.10 [26.04]=ubuntu-base-26.04.1 [26.10]=ubuntu-base-26.10-beta)
for v in "${!IMG[@]}"; do
  sudo rm -rf "rootfs/$v"; sudo mkdir -p "rootfs/$v"
  sudo tar -xzf "downloads/${IMG[$v]}-base-arm64.tar.gz" -C "rootfs/$v"
done
sudo chroot rootfs/26.10 /bin/bash -c 'mkdir -p /opt/gnushim && for g in /usr/bin/gnu*; do ln -sf "$g" "/opt/gnushim/${g#/usr/bin/gnu}"; done; ls /opt/gnushim | wc -l'
