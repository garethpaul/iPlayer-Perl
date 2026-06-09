# PERL5LIB Trailing Slash Duplicate Guard

status: completed

## Context

`run.pl` prepends existing local dependency paths before preserving an external
`PERL5LIB` value. The duplicate guard skipped exact matches, but an environment
entry with a trailing slash could still cause the wrapper to prepend the same
local path again.

## Objectives

- Normalize wrapper-managed path entries before duplicate comparison.
- Preserve the original external `PERL5LIB` string after any missing local paths.
- Keep missing local dependency directories filtered out.
- Extend the static baseline so trailing slash duplicate handling remains
  visible.
- Document the guard alongside the wrapper path separator and duplicate-path
  behavior.

## Verification

- `make check`
- `perl -c run.pl`
- `git diff --check`
