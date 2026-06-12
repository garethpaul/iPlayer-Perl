# Wrapper Submodule Library Paths Plan

status: completed

## Context

`.gitmodules` declares local dependency submodules for `mouse`, `mousex-getopt`, and `mousex-nativetraits`. `run.pl` prepends local library paths for two of those dependencies before executing `get_iplayer`, leaving `mousex-getopt` out of `PERL5LIB`.

## Objectives

- Add the missing `mousex-getopt` local library path to `run.pl`.
- Preserve shell-free argument forwarding.
- Preserve existing `PERL5LIB` values and Perl's configured path separator.
- Extend the static baseline so wrapper library paths stay aligned with declared submodules.

## Verification

- `make check`
- `perl -c run.pl`
- `git diff --check`
