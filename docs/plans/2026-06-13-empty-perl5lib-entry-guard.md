# Empty PERL5LIB Entry Guard

status: completed

## Context

Empty `PERL5LIB` segments represent the current working directory. Preserving
leading, repeated, or trailing separators can therefore add an untrusted launch
directory to Perl's module search path before the wrapper execs `get_iplayer`.

## Requirements

- Parse existing `PERL5LIB` into non-empty entries.
- Preserve non-empty entry order, canonical dedupe, platform separators, local
  dependency precedence, and exact argument forwarding.
- Rebuild `PERL5LIB` from validated entries rather than appending the raw value.
- Add TAP coverage, static contracts, documentation, and completed evidence.

## Scope Boundaries

- Do not download media, contact services, change get_iplayer arguments, or
  alter packaged dependency installation.

## Verification

- All Make gates, `prove -v t`, Perl/Python syntax, mutation tests, and diff
  checks.

## Work Completed

- Parsed the inherited `PERL5LIB` with the configured platform separator,
  removed empty entries, rebuilt the environment from validated entries, and
  unset the variable when no validated entries remain.
- Preserved non-empty entry order, canonical duplicate suppression, existing
  local dependency precedence, and exact wrapper argument forwarding.
- Added TAP and static contracts plus user-facing security and maintenance
  documentation for the empty-entry boundary.

## Verification Completed

- `make lint`, `make test`, `make build`, and `make check` passed.
- `prove -v t`, `perl -c run.pl`, `perl -c t/run-wrapper.t`, and
  `python3 -m py_compile scripts/check-baseline.py` passed.
- Six hostile mutations were rejected: removing empty-entry filtering,
  removing trailing-empty split preservation, restoring raw environment
  appending, removing the TAP assertion, reverting plan completion, and
  removing recorded verification evidence.
- An additional review-driven mutation that removed the all-empty cleanup was
  rejected by the focused TAP regression.
