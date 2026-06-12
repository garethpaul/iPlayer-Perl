# CI Baseline

status: completed

## Context

The portfolio remediation plan calls for lightweight CI on active repos with
passing local checks. The current iPlayer Perl baseline is static and
dependency-light: it validates Perl syntax, help output, wrapper behavior,
submodule metadata, docs, and local artifact ignores without performing media
downloads.

## Completed Scope

- Added a GitHub Actions workflow for pushes, pull requests, and manual runs.
- Configured CI to run `make check`, which delegates to
  `scripts/check-baseline.py`.
- Extended the static baseline and docs so the CI gate remains visible.

## Verification

- `make check`
- `git diff --check`
