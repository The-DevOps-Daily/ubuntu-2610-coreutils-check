#!/usr/bin/env bash
# Build the input files every case runs against. Called by 03-run-cases.sh into
# a fresh /work inside each rootfs, so every case starts from the same state.
set -euo pipefail
d="$1"; mkdir -p "$d"; cd "$d"
printf 'alpha\nbeta\ngamma\ndelta\nepsilon\n' > words.txt
printf '10K\n2M\n1G\n512\n3K\n' > sizes.txt
printf 'v1.10\nv1.2\nv1.9\nv2.0\nv1.2.1\n' > versions.txt
printf 'bob,30,ops\nalice,25,dev\ncarol,35,sre\ndave,25,dev\n' > people.csv
printf 'b\nB\na\nA\n_c\n1\n' > mixed.txt
printf 'apple\napple\nbanana\napple\ncherry\ncherry\n' > dup.txt
printf 'héllo wörld\nnaïve café\n' > utf8.txt
printf 'line1\r\nline2\r\n' > crlf.txt
printf 'root:x:0:0:root:/root:/bin/bash\nnobody:x:65534:65534:nobody:/nonexistent:/usr/sbin/nologin\n' > passwd.txt
mkdir -p dir/sub && printf 'x' > dir/a && printf 'yy' > dir/sub/b && printf 'z' > dir/.hidden
head -c 100000 /dev/zero > zeros.bin
printf 'hello\n' > hello.txt
sha256sum hello.txt > hello.sha256
printf '0000000000000000000000000000000000000000000000000000000000000000  hello.txt\n' > bad.sha256
mkdir -p exists && printf 'old\n' > exists/target.txt && printf 'new\n' > target.txt
touch -d '2020-01-02 03:04:05 UTC' hello.txt words.txt dir/a
chmod 644 hello.txt; chmod 600 words.txt
