# Secure Wrapper Directory

## Status: Completed

## Context

`run.pl` validated the `get_iplayer` file's type, ownership, mode, size, and
canonical path, but only canonicalized the directory containing both the
wrapper and executable. A different user with write access to that directory
could replace a path between validation and execution even when the checked
file itself was not writable.

## Design

Validate `$Bin` with the existing `secure_directory()` helper before deriving
local libraries or the executable path. This requires an absolute, existing,
non-symlink directory owned by root or the current user and not writable by the
group or world.

Checking only the executable again was rejected because directory write access
controls path replacement. Adding a second near-duplicate helper was rejected
because inherited `PERL5LIB` entries already use the required policy.

## Work Completed

- Applied the existing secure-directory policy to the wrapper directory.
- Added explicit failure text for unsafe ownership or write permissions.
- Added TAP coverage for a world-writable application directory.
- Set positive fixture directories explicitly to mode `0755`, making the suite
  deterministic under collaborative umasks such as `0002`.
- Added a hostile source mutation that reverts to canonicalization only.

## Verification

- `prove -v t/run-wrapper.t`
- `umask 0002; prove -v t/run-wrapper.t`
- `/usr/bin/make check`
- `git diff --check`

## Perl Evidence

- Perl's security guidance describes non-writable absolute path directories as
  a standard taint-mode precaution:
  https://perldoc.perl.org/perlsec
- Perl's indirect-object list form keeps `exec` arguments out of a shell; the
  existing wrapper continues to use it:
  https://perldoc.perl.org/functions/exec

## Scope Boundaries

- Argument forwarding, `PERL5LIB` ordering, dependency paths, entrypoint size
  and mode checks, historical client code, and content-access behavior are
  unchanged.
- No BBC service request, credential use, media download, or external player
  invocation was performed.
