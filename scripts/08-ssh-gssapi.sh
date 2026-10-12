#!/usr/bin/env bash
# What a fresh 26.10 OpenSSH client does with GSSAPI options that older configs
# carry: on the command line, in ~/.ssh/config, and in the shipped ssh_config.
# Needs 07-packages.sh first (it installs openssh-client in each rootfs).
set -uo pipefail
cd "$(dirname "$0")/.."
for v in 26.04 26.10; do
  echo "== $v"
  sudo mount --bind /dev "rootfs/$v/dev"
  sudo chroot rootfs/$v /bin/bash -c '
    ssh -V 2>&1
    echo "-- GSSAPI lines in /etc/ssh/ssh_config:"; grep -n -i gssapi /etc/ssh/ssh_config || echo "(none)"
    echo "-- ssh -G with -o GSSAPIAuthentication=yes:"; ssh -G -o GSSAPIAuthentication=yes example.com >/dev/null; echo "exit=$?"
    mkdir -p /root/.ssh; printf "Host *\n    GSSAPIAuthentication yes\n    GSSAPIDelegateCredentials no\n" > /root/.ssh/config
    echo "-- ssh -G with GSSAPI lines in ~/.ssh/config:"; ssh -G example.com 2>&1 >/dev/null | head -3; ssh -G example.com >/dev/null 2>&1; echo "exit=$?"
    rm -f /root/.ssh/config
  ' 2>&1
  sudo umount "rootfs/$v/dev"
done | tee results/ssh-gssapi.txt
