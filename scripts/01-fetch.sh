#!/usr/bin/env bash
# Download the four Ubuntu base images and check them against Canonical's SHA256SUMS.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p downloads
fetch() { # dir file
  local base="https://cdimage.ubuntu.com/ubuntu-base/releases/$1"
  curl -fsS -o "downloads/$2" "$base/$2"
  curl -fsS "$base/SHA256SUMS" | grep " \*\?$2\$" | sed 's/ \*/  /' | (cd downloads && sha256sum -c -)
}
fetch 24.04/release ubuntu-base-24.04.5-base-arm64.tar.gz
fetch 25.10/release ubuntu-base-25.10-base-arm64.tar.gz
fetch 26.04/release ubuntu-base-26.04.1-base-arm64.tar.gz
fetch 26.10/beta    ubuntu-base-26.10-beta-base-arm64.tar.gz
