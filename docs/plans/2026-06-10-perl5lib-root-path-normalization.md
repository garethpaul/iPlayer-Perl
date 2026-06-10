# PERL5LIB Root Path Normalization

status: completed

## Context

`run.pl` normalizes `PERL5LIB` entries by trimming trailing path separators
before duplicate comparison. That handles normal directory variants like
`deps/mouse/lib/`, but root path entries such as `/` or `C:\` should not be
trimmed into an empty or malformed comparison key.

## Completed Scope

- Preserved Unix and drive-root style path entries before trimming ordinary
  trailing separators.
- Kept canonical path comparison and existing duplicate detection unchanged for
  normal dependency library paths.
- Extended the static baseline and docs so root path normalization remains
  explicit without changing argument forwarding or download behavior.

## Verification

- `make check`
- `python3 scripts/check-baseline.py`
- `git diff --check`
