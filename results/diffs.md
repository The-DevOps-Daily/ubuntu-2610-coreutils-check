# Case differences

## version-ls

`ls --version | head -1`

**gnu-24.04** (rc 0)
```text
ls (GNU coreutils) 9.4
```

**mixed-26.04** (rc 0)
```text
ls (uutils coreutils) 0.8.0
```

**gnu-26.10** (rc 0)
```text
ls (GNU coreutils) 9.10
```

**uutils-26.10** (rc 0)
```text
ls (uutils coreutils) 0.12.0
```

## version-date

`date --version | head -1`

**gnu-24.04** (rc 0)
```text
date (GNU coreutils) 9.4
```

**mixed-26.04** (rc 0)
```text
date (uutils coreutils) 0.8.0
```

**gnu-26.10** (rc 0)
```text
date (GNU coreutils) 9.10
```

**uutils-26.10** (rc 0)
```text
date (uutils coreutils) 0.12.0
```

## detect-gnu-date

`if date --version 2>/dev/null | grep -q GNU; then echo gnu-path; else echo bsd-path; fi`

**gnu-24.04** (rc 0)
```text
gnu-path
```

**mixed-26.04** (rc 0)
```text
bsd-path
```

**gnu-26.10** (rc 0)
```text
gnu-path
```

**uutils-26.10** (rc 0)
```text
bsd-path
```

## detect-gnu-stat

`if stat --version 2>/dev/null | grep -q GNU; then echo gnu-path; else echo bsd-path; fi`

**gnu-24.04** (rc 0)
```text
gnu-path
```

**mixed-26.04** (rc 0)
```text
bsd-path
```

**gnu-26.10** (rc 0)
```text
gnu-path
```

**uutils-26.10** (rc 0)
```text
bsd-path
```

## ls-bad-option

`ls --bogus`

**gnu-24.04** (rc 2)
```text
[stderr] ls: unrecognized option '--bogus'
Try 'ls --help' for more information.
```

**mixed-26.04** (rc 2)
```text
[stderr] error: unexpected argument '--bogus' found

  tip: to pass '--bogus' as a value, use '-- --bogus'

Usage: ls [OPTION]... [FILE]...

For more information, try '--help'.
```

**gnu-26.10** (rc 2)
```text
[stderr] ls: unrecognized option '--bogus'
Try 'ls --help' for more information.
```

**uutils-26.10** (rc 2)
```text
[stderr] error: unexpected argument '--bogus' found

  tip: to pass '--bogus' as a value, use '-- --bogus'

Usage: ls [OPTION]... [FILE]...

For more information, try '--help'.
```

## cp-no-clobber

`cp -n target.txt exists/target.txt; echo "rc=$?"; cat exists/target.txt`

**gnu-24.04** (rc 0)
```text
rc=0
old
[stderr] cp: warning: behavior of -n is non-portable and may change in future; use --update=none instead
```

**mixed-26.04** (rc 0)
```text
rc=0
old
[stderr] cp: warning: behavior of -n is non-portable and may change in future; use --update=none instead
```

**gnu-26.10** (rc 0)
```text
rc=0
old
[stderr] cp: warning: behavior of -n is non-portable and may change in future; use --update=none instead
```

**uutils-26.10** (rc 0)
```text
rc=0
old
```

## date-invalid

`date -d 'not a date'`

**gnu-24.04** (rc 1)
```text
[stderr] date: invalid date ‘not a date’
```

**mixed-26.04** (rc 1)
```text
[stderr] date: invalid date 'not a date'
```

**gnu-26.10** (rc 1)
```text
[stderr] date: invalid date ‘not a date’
```

**uutils-26.10** (rc 1)
```text
[stderr] date: invalid date 'not a date'
```

## cut-chars-utf8

`cut -c1-4 utf8.txt`

**gnu-24.04** (rc 0)
```text
hél
naï
```

**mixed-26.04** (rc 0)
```text
hél
naï
```

**gnu-26.10** (rc 0)
```text
hél
naï
```

**uutils-26.10** (rc 0)
```text
héll
naïv
```

## base64-bad

`echo 'not*base64' | base64 -d; echo "rc=$?"`

**gnu-24.04** (rc 0)
```text
��rc=1
[stderr] base64: invalid input
```

**mixed-26.04** (rc 0)
```text
rc=1
[stderr] base64: error: invalid input
```

**gnu-26.10** (rc 0)
```text
��rc=1
[stderr] base64: invalid input
```

**uutils-26.10** (rc 0)
```text
rc=1
[stderr] base64: error: invalid input
```

## timeout-kill

`timeout -s KILL 1 sleep 5; echo "rc=$?"`

**gnu-24.04** (rc 0)
```text
rc=137
[stderr] /bin/bash: line 1: 929172 Killed                  timeout -s KILL 1 sleep 5
```

**mixed-26.04** (rc 0)
```text
rc=124
```

**gnu-26.10** (rc 0)
```text
rc=137
[stderr] /bin/bash: line 1: 933754 Killed                     timeout -s KILL 1 sleep 5
```

**uutils-26.10** (rc 0)
```text
rc=124
```

## printf-invalid-num

`env printf '%d\n' abc; echo "rc=$?"`

**gnu-24.04** (rc 0)
```text
0
rc=1
[stderr] printf: ‘abc’: expected a numeric value
```

**mixed-26.04** (rc 0)
```text
0
rc=1
[stderr] printf: 'abc': expected a numeric value
```

**gnu-26.10** (rc 0)
```text
0
rc=1
[stderr] printf: ‘abc’: expected a numeric value
```

**uutils-26.10** (rc 0)
```text
0
rc=1
[stderr] printf: 'abc': expected a numeric value
```

## ln-existing

`ln -s hello.txt words.txt`

**gnu-24.04** (rc 1)
```text
[stderr] ln: failed to create symbolic link 'words.txt': File exists
```

**mixed-26.04** (rc 1)
```text
[stderr] ln: Already exists
```

**gnu-26.10** (rc 1)
```text
[stderr] ln: failed to create symbolic link 'words.txt': File exists
```

**uutils-26.10** (rc 1)
```text
[stderr] ln: failed to create symbolic link 'words.txt': Already exists
```
