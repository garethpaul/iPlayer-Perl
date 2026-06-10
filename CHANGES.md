# Changes

## 2026-06-10

- Added pinned, read-only Linux hosted validation with packaged LWP modules for
  Perl syntax, versioned help output, wrapper guardrails, and static resources.
- Preserved root path entries during `PERL5LIB` normalization so duplicate
  checks do not trim `/` or drive-root values into malformed comparison keys.

## 2026-06-09

- Added local `make lint`, `make test`, and `make build` gate aliases for the
  static Perl wrapper baseline.
- Skipped duplicate local library paths when `PERL5LIB` already contains one of
  the wrapper-managed dependency paths.
- Normalized wrapper-managed `PERL5LIB` entries during duplicate checks so
  trailing slash variants are not prepended again.
- Compared existing `PERL5LIB` entries by canonical path when possible so
  relative or symlinked local dependency paths are not prepended again.

## 2026-06-08

- Replaced the `run.pl` shell backtick wrapper with an argument-preserving `exec` call.
- Preserved local dependency path handling while keeping existing `PERL5LIB` values.
- Added the missing `mousex-getopt` local library path to the wrapper.
- Switched submodule metadata to HTTPS submodule URLs for the Mouse dependency
  mirrors.
- Switched wrapper `PERL5LIB` path separator handling to Perl's configured value.
- Filtered wrapper `PERL5LIB` entries to existing local library paths before preserving external values.
- Fixed legacy RDF hash dereferences that fail under modern Perl syntax checks.
- Added `make check` with Perl syntax validation, help-output verification, man/SVG parsing, wrapper execution guardrails, and content-access documentation checks.
