# Changes

## 2026-06-08

- Replaced the `run.pl` shell backtick wrapper with an argument-preserving `exec` call.
- Preserved local dependency path handling while keeping existing `PERL5LIB` values.
- Fixed legacy RDF hash dereferences that fail under modern Perl syntax checks.
- Added `make check` with Perl syntax validation, help-output verification, man/SVG parsing, wrapper execution guardrails, and content-access documentation checks.
