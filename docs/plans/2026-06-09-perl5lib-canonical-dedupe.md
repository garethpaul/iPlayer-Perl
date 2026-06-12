# PERL5LIB Canonical Path Dedupe

status: completed

## Context

The wrapper already avoided duplicate local dependency paths in `PERL5LIB` and
treated trailing slash variants as duplicates. It still compared raw strings,
so an existing relative or symlinked path could point at the same dependency
directory and still be prepended again.

## Completed Scope

- Added canonical path comparison for existing path entries when the entry is
  resolvable on disk.
- Kept unresolved and empty path entries preserved as their normalized string
  values.
- Reused canonical comparison for wrapper-managed local library paths.
- Extended the static baseline and docs to preserve the guardrail.

## Verification

- `make lint`
- `make test`
- `make build`
- `make check`
- `git diff --check`
