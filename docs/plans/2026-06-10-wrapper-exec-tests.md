# Wrapper Exec Tests

status: completed

## Problem

The wrapper's path construction is statically checked and `--help` reaches the
real script, but no isolated test proves that `exec` preserves arbitrary
arguments and constructs `PERL5LIB` without duplicate local library paths.

## Scope

- Run a copied wrapper against a temporary fake `get_iplayer` executable.
- Verify arguments containing spaces and option-like values are preserved.
- Verify existing `PERL5LIB` content remains present.
- Verify local dependency paths are prepended once after canonical comparison.
- Run the core-Perl test with `prove` from the canonical `make check` gate.

## Verification

- `prove -v t`
- `make lint`
- `make test`
- `make build`
- `make check`
- mutation check that breaks argument forwarding
- `git diff --check`
