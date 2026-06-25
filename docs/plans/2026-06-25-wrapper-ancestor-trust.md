# Wrapper Ancestor Trust

status: completed

## Problem

The wrapper validated `$Bin` itself, but a different user with write access to
a non-sticky ancestor could rename or replace that directory entry after the
check. Final-file and final-directory validation therefore did not close the
full pathname replacement boundary.

## Change

Walk the canonical directory chain to the filesystem root. Every ancestor must
be owned by root or the current user. Group/world-writable ancestors are
rejected unless the sticky bit prevents unrelated users from replacing owned
entries, preserving ordinary `/tmp`-based tests and installations.

## Verification Completed

- RED reproduced with a safe nested wrapper below a mode `0775` parent.
- All 21 TAP wrapper assertions passed after implementation.
- All 21 TAP assertions also passed under collaborative umask `0002`.
- The Python static baseline requires the ancestor walk and sticky exception.
- Nine hostile mutations were rejected, including removal of ancestor checks.
- `/usr/bin/make check` and `git diff --check` passed.
- No live BBC request, credential, download, stream, or player was used.
