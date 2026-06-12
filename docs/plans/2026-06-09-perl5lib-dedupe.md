# PERL5LIB Duplicate Path Guard

status: completed

## Context

`run.pl` prepends local dependency paths for the preserved Mouse submodules and
then preserves any external `PERL5LIB` value. If a caller already included one
of those local paths, the wrapper could add the same path twice.

## Objectives

- Parse existing `PERL5LIB` entries with Perl's configured path separator.
- Skip wrapper-managed local dependency paths that are already present.
- Preserve the external `PERL5LIB` string exactly after any missing local paths.
- Extend the static baseline so duplicate local library paths remain covered.

## Verification

- `make check`
- `perl -c run.pl`
- `git diff --check`
