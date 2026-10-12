#!/usr/bin/env python3
"""Compare the setups case by case and write results/summary.tsv and results/diffs.md.

A case "differs" when stdout, stderr or the exit code is not byte-identical.
The main comparison is gnu-26.10 vs uutils-26.10: same OS, same files, only
the coreutils implementation changes. gnu-24.04 vs uutils-26.10 is the upgrade
an LTS user makes.
"""
import pathlib, sys

root = pathlib.Path(__file__).resolve().parent.parent
res = root / "results"
cases = [l.split("\t", 1) for l in (root / "cases.tsv").read_text().splitlines() if l and not l.startswith("#")]

def load(setup, cid):
    d = res / setup
    return tuple((d / f"{cid}.{k}").read_bytes() for k in ("out", "err", "rc"))

def what(a, b):
    return ",".join(n for n, x, y in zip(("stdout", "stderr", "rc"), a, b) if x != y) or "same"

pairs = [("gnu-26.10", "uutils-26.10"), ("gnu-24.04", "uutils-26.10"), ("gnu-24.04", "gnu-26.10"), ("gnu-24.04", "mixed-25.10"), ("gnu-24.04", "mixed-26.04"), ("mixed-26.04", "uutils-26.10")]
rows, md = [], ["# Case differences\n"]
for cid, cmd in cases:
    row = [cid] + [what(load(a, cid), load(b, cid)) for a, b in pairs]
    rows.append(row)
    if row[1] != "same":
        md.append(f"## {cid}\n\n`{cmd}`\n")
        for setup in ("gnu-24.04", "mixed-26.04", "gnu-26.10", "uutils-26.10"):
            o, e, rc = load(setup, cid)
            md.append(f"**{setup}** (rc {rc.decode().strip()})\n```text\n{o.decode(errors='replace')}{('[stderr] ' + e.decode(errors='replace')) if e else ''}```\n")
with open(res / "summary.tsv", "w") as f:
    f.write("case\t" + "\t".join(f"{a} vs {b}" for a, b in pairs) + "\n")
    for r in rows:
        f.write("\t".join(r) + "\n")
(res / "diffs.md").write_text("\n".join(md))
for i, (a, b) in enumerate(pairs, 1):
    n = sum(1 for r in rows if r[i] != "same")
    print(f"{a} vs {b}: {n} of {len(rows)} cases differ")
