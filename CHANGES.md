# Changes

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
