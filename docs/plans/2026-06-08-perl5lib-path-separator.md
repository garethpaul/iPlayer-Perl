# PERL5LIB Path Separator Plan

status: completed

## Context

`run.pl` prepends local dependency directories to `PERL5LIB` before executing `get_iplayer`. The wrapper already preserves argument boundaries with `exec`, but its library path assembly used a Unix-specific separator.

## Objectives

- Keep argument forwarding shell-free.
- Preserve local dependency lookup and any existing `PERL5LIB` value.
- Use Perl's configured library path separator instead of a hardcoded shell-specific separator.
- Extend `make check` so future wrapper changes preserve the path separator behavior.

## Verification

- `make check`
- `perl -c run.pl`
- `git diff --check`
