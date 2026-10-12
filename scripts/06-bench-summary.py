#!/usr/bin/env python3
"""Summarise results/bench.tsv: median of runs 2..N per workload and
implementation (run 1 is a warm-up), the spread, and uutils time / GNU time."""
import csv, statistics, pathlib, collections

res = pathlib.Path(__file__).resolve().parent.parent / "results"
runs = collections.defaultdict(list)
with open(res / "bench.tsv") as f:
    for row in csv.DictReader(f, delimiter="\t"):
        if int(row["run"]) == 1:
            continue
        runs[(row["workload"], row["impl"])].append(float(row["seconds"]))

order = list(dict.fromkeys(w for w, _ in runs))
lines = ["workload\tgnu_median_s\tuutils_median_s\tuutils_over_gnu\tgnu_range\tuutils_range\tn"]
for w in order:
    g, u = sorted(runs[(w, "gnu")]), sorted(runs[(w, "uutils")])
    gm, um = statistics.median(g), statistics.median(u)
    lines.append(f"{w}\t{gm:.3f}\t{um:.3f}\t{um / gm:.2f}\t{g[0]:.2f}-{g[-1]:.2f}\t{u[0]:.2f}-{u[-1]:.2f}\t{len(g)}")
(res / "bench-summary.tsv").write_text("\n".join(lines) + "\n")
print("\n".join(lines))
