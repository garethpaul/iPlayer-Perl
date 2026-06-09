# HTTPS Submodule URLs

status: completed

## Context

The repository preserves local dependency submodule metadata for Mouse,
MouseX::Getopt, and MouseX::NativeTraits. The existing `.gitmodules` entries
used unauthenticated `git://` URLs, which are harder to audit and can fail in
modern locked-down environments.

## Objectives

- Replace `git://` submodule URLs with reachable HTTPS mirrors.
- Preserve the existing submodule paths used by `run.pl`.
- Extend the static baseline so unauthenticated submodule URLs do not return.
- Document the dependency metadata guardrail.

## Verification

- `python3 scripts/check-baseline.py`
- `make check`
- `git diff --check`
