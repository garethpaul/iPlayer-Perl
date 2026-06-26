# Changes

## 2026-06-25T20:16:00-0700 — P2 documentation — refresh verified roadmap

### Summary
Removed completed runtime and CLI-help work from the future roadmap and tied
the current vision to the executable baseline.

### Work completed
- Recorded the maintained Perl, Python, and Perl-module expectations in the vision.
- Documented that both direct and wrapped help paths execute offline.
- Kept live BBC content access explicitly outside that verification claim.

### Validation
- `make check` passes the static, TAP, and hostile-mutation gates.

### Blockers
- No live BBC request, credential, download, stream, or player was used.

### Next action
- Clarify the preserved snapshot's upstream relationship and update policy.

## 2026-06-25T20:01:00-0700 — P2 security testing — cycle: runtime environment scrub proof

### Summary
Converted the wrapper's startup-environment scrub from a source-only assertion
into an exec-boundary runtime guarantee.

### Work completed
- Extended the fake `get_iplayer` child to report reviewed environment values.
- Passed hostile interpreter and shell startup variables through the real wrapper.
- Asserted seven variables are unset and `PATH` is fixed before child execution.
- Added a runtime hostile mutation that preserves inherited `IFS`.

### Threads
- None; the focused test improvement was implemented directly.

### Files changed
- `t/run-wrapper.t`, `tests/hostile-mutations.sh`, static contracts, guidance,
  and `docs/plans/2026-06-25-wrapper-environment-scrub.md`.

### Validation
- `prove -v t/run-wrapper.t` — 22 TAP assertions passed.
- `umask 0002; prove -v t/run-wrapper.t` — the same 22 assertions passed.
- `make lint`, `make test`, `make build`, and `make check` — all passed with ten
  hostile mutations rejected.
- Hosted baseline runs `28214345599` and `28214347029` and Actions/Python
  CodeQL run `28214345831` passed on the reviewed implementation head.
- Codex review was attempted but blocked by OpenAI API HTTP 401; manual
  exact-head security and regression review found no findings.

### Bugs / findings
- P2: source checks did not prove the executed child received the scrubbed environment.

### Blockers
- No live BBC request, credential, download, stream, or player was used.

### Next action
- Merge the final hosted-green head and retain this exec-boundary assertion for
  future wrapper environment changes.

## 2026-06-25T21:20:45Z — P1 security — cycle: canonical wrapper ancestor trust

### Summary
Closed the remaining directory-entry replacement gap by validating the full
canonical ancestor chain before loading local libraries or executing the
historical client.

### Work completed
- Rejected non-sticky group/world-writable ancestors while preserving trusted
  sticky shared roots such as `/tmp`.
- Added TAP coverage for a safe wrapper nested below an unsafe parent.
- Added static source contracts and a ninth hostile mutation for ancestor checks.
- Updated security, maintenance, and contributor guidance.

### Threads
- Started: wrapper ancestor-chain ownership and mode validation.
- Continued: taint-mode environment cleanup, final-directory trust, entrypoint
  shape/ownership checks, and list-form argument-preserving `exec`.
- Stopped: none.

### Files changed
- `run.pl`, `t/run-wrapper.t`, `scripts/check-baseline.py`,
  `tests/hostile-mutations.sh`, documentation, and
  `docs/plans/2026-06-25-wrapper-ancestor-trust.md`.

### Validation
- RED: the nested wrapper executed below a mode `0775` parent.
- GREEN: all 21 TAP assertions pass, including sticky `/tmp` ancestry.
- `umask 0002; prove -v t/run-wrapper.t` passes all 21 assertions.
- `/usr/bin/make check` passes static checks and nine hostile mutations.

### Bugs / findings
- P1: validating only the final wrapper directory did not prevent another user
  from replacing its directory entry through a non-sticky writable ancestor.

### Blockers
- Live BBC content, credentials, media downloads, and optional dependency
  submodules remain outside the maintained offline wrapper surface.

### Next action
- Verify the exact reviewed head in hosted Linux, then retain ancestor-chain
  validation for future wrapper and local-library path changes.

## 2026-06-25 04:49 - P1 - Reject writable wrapper directories

### Summary
Closed the executable-parent trust gap so the taint-mode wrapper will not launch
`get_iplayer` from a directory another user can modify.

### Work completed
- Reused `secure_directory()` for the wrapper directory before resolving local
  libraries or the executable.
- Added TAP coverage for group/world-writable wrapper directories.
- Added a hostile mutation that removes the new directory validation.
- Stabilized positive wrapper fixtures at mode `0755` after Codex review found
  common collaborative umasks could otherwise invalidate them.

### Threads
- Started: none — work completed directly in the current repository.
- Continued: none.
- Stopped: none.

### Files changed
- `run.pl` — enforced wrapper-directory ownership and mode checks.
- `t/run-wrapper.t` — added failing-then-passing writable-directory regressions.
- `scripts/check-baseline.py`, `tests/hostile-mutations.sh` — protected the new
  source contract.
- Documentation and plan files — recorded the security boundary and evidence.

### Validation
- `prove -v t/run-wrapper.t` — failed before implementation, then passed all
  19 TAP cases after the fix.
- `umask 0002; prove -v t/run-wrapper.t` — passed after the review fix.
- `/usr/bin/make check` — passed static checks, TAP tests, and eight hostile
  mutations.
- `git diff --check` — passed.

### Bugs / findings
- P1: validating only the executable file allowed a writable parent directory,
  where another user could replace the checked path before wrapper execution.
- P2 review finding: the initial test fixture inherited the caller's umask and
  needed an explicit safe directory mode.

### Blockers
- The historical BBC service and optional dependency submodules remain outside
  the maintained offline wrapper surface.

### Next action
- Open a PR and complete Codex plus hosted review before merge.

## 2026-06-13

- Made all Make verification aliases location-independent when invoked through
  an absolute Makefile path.
- Removed empty `PERL5LIB` entries before the wrapper rebuilds the module search
  path, preventing the launch directory from being added implicitly.
- Enabled startup taint mode and rejected relative, symlinked, writable, or
  missing library paths before launching a bounded regular `get_iplayer` file.
- Added location-independent hostile mutation checks and updated pinned CI
  actions.

## 2026-06-12

- Documented radio mode inspection, ordered higher-quality AAC preferences, and
  the HTTP proxy/RTMP endpoint boundary with implementation-backed checks.

## 2026-06-10

- Added core-Perl wrapper exec tests for exact argument forwarding and
  canonical `PERL5LIB` duplicate suppression.
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
