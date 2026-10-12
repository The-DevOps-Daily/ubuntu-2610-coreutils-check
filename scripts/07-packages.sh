#!/usr/bin/env bash
# Package-level checks that need apt: which D-Bus implementation each release
# installs, where dbus-run-session comes from, and whether a fresh OpenSSH
# client still understands GSSAPI options. Output: results/packages-<ver>.txt
set -uo pipefail
cd "$(dirname "$0")/.."
for v in 24.04 26.04 26.10; do
  r=rootfs/$v; out=results/packages-$v.txt
  sudo cp /etc/resolv.conf "$r/etc/resolv.conf"
  sudo mount -t proc proc "$r/proc"; sudo mount --bind /dev "$r/dev"
  sudo chroot "$r" /usr/bin/env -i PATH=/usr/sbin:/usr/bin:/sbin:/bin DEBIAN_FRONTEND=noninteractive LC_ALL=C.UTF-8 /bin/bash -c '
    apt-get update -qq >/dev/null 2>&1
    echo "## providers of default-dbus-system-bus"; apt-cache showpkg default-dbus-system-bus | sed -n "/Reverse Provides/,\$p"
    echo "## dbus implementation pulled in by systemd-sysv"; apt-get -s install --no-install-recommends systemd-sysv 2>/dev/null | grep -E "^Inst (dbus|dbus-broker|dbus-daemon|dbus-bin|libdbus)" | cut -d" " -f2
    echo "## dbus implementation pulled in by the dbus package"; apt-get -s install --no-install-recommends dbus 2>/dev/null | grep -E "^Inst (dbus|dbus-broker|dbus-daemon|dbus-bin)" | cut -d" " -f2
    echo "## archive component"; for p in dbus dbus-broker dbus-daemon dbus-bin; do printf "%s: " $p; apt-cache show $p 2>/dev/null | grep -m1 -E "^Section" || echo "not in archive"; done
    echo "## openssh-client candidate"; apt-cache policy openssh-client | sed -n 1,3p
    apt-get install -y -qq --no-install-recommends openssh-client >/dev/null 2>&1
    echo "## ssh -V"; ssh -V 2>&1
    echo "## ssh with GSSAPIAuthentication=yes"; ssh -G -o GSSAPIAuthentication=yes example.com 2>&1 | grep -iE "gssapi|unsupported|bad configuration" | head -3
  ' > "$out" 2>&1
  sudo umount "$r/proc" "$r/dev"
  echo "== $v"; cat "$out"
done
