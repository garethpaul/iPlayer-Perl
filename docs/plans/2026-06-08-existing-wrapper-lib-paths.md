# Existing Wrapper Library Paths Plan

status: completed

## Context

`run.pl` knows about the local `mouse`, `mousex-getopt`, and
`mousex-nativetraits` submodule library paths. Those submodules may not be
checked out in every clone, so the wrapper should not prepend missing local
directories to `PERL5LIB`.

## Objectives

- Keep declared submodule library path strings visible in `run.pl`.
- Add only existing local library paths to `PERL5LIB`.
- Preserve any existing external `PERL5LIB` value.
- Avoid setting an empty `PERL5LIB` when no local or external entries exist.
- Extend the static baseline so wrapper path filtering remains covered.

## Verification

- `make check`
- `perl -c run.pl`
- `git diff --check`
