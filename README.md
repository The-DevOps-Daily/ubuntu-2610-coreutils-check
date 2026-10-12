# ubuntu-2610-coreutils-check

Run 162 common shell-script commands with GNU coreutils and with the Rust uutils coreutils that Ubuntu 26.10 ships for every tool, and see exactly what changes. Same files, same OS, only the implementation differs.

```bash
scripts/01-fetch.sh      # download Ubuntu 24.04.5, 25.10, 26.04.1 and 26.10 beta base images (arm64), verify SHA256SUMS
scripts/02-extract.sh    # unpack each into rootfs/<version>; add a GNU shim dir in 26.10
scripts/03-run-cases.sh  # run every line of cases.tsv in five setups (needs sudo for chroot)
scripts/04-compare.py    # results/summary.tsv and results/diffs.md
scripts/05-bench.sh      # GNU 9.10 vs uutils 0.12.0 timings inside 26.10 (RUNS=9)
scripts/06-bench-summary.py
scripts/07-packages.sh   # D-Bus provider and OpenSSH client per release (apt in the chroot)
scripts/08-ssh-gssapi.sh # what OpenSSH 10.5 does with GSSAPI options
```

The images are `arm64` because it was run on a Raspberry Pi 4; change the file names in `01-fetch.sh` for `amd64`.

## The five setups

| Setup | Release | Coreutils |
|---|---|---|
| `gnu-24.04` | 24.04.5 LTS | GNU 9.4 |
| `mixed-25.10` | 25.10 | uutils 0.2.2, GNU for cp, mv, rm, chmod, chown, df, true |
| `mixed-26.04` | 26.04.1 LTS | uutils 0.8.0, GNU for cp, mv, rm, df, true |
| `uutils-26.10` | 26.10 beta | uutils 0.12.0 for every tool |
| `gnu-26.10` | 26.10 beta | GNU 9.10 (the `gnu*` binaries Ubuntu still ships), first in `PATH` |

`gnu-26.10` vs `uutils-26.10` is the clean comparison: the same rootfs and files, only the implementation changes.

## Files

- `cases.tsv`: one command per line, run with `bash -c` in `/work`, `LC_ALL=C.UTF-8`, `TZ=UTC`.
- `scripts/fixtures.sh`: the input files each case starts from.
- `results/<setup>/<case>.{out,err,rc}`: raw stdout, stderr and exit code.
- `results/summary.tsv`, `results/diffs.md`: the comparison.
- `results/bench.tsv`, `results/bench-summary.tsv`: every timed run and the medians (run 1 is a warm-up and is dropped).
- `results/packages-*.txt`, `results/ssh-gssapi.txt`: package checks.

Results and the write-up: see the DevOps Daily post linked in the repo description.

License: MIT
