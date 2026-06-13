# Empty PERL5LIB Entry Guard

status: planned

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
