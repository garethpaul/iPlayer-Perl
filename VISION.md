## iPlayer Perl Vision

This document explains the current state and direction of the project.
Project overview and developer docs: [`README.md`](README.md)

iPlayer Perl is a copy of `get_iplayer`, a Perl tool for accessing BBC iPlayer
TV and radio content.

The repository is useful as a preserved Perl command-line tool with install
notes, license text, a man page, and the main `get_iplayer` script.

The goal is to keep the tool understandable while respecting content access
rules, licensing, and legacy runtime assumptions.

Current baseline: `make lint`, `make test`, `make build`, and `make check` run
`scripts/check-baseline.py` to verify Perl syntax, help output, compressed man
page readability, safe wrapper argument forwarding, modern Perl compatibility,
ignored downloaded media, credential and cookie boundaries, HTTPS submodule
metadata, empty PERL5LIB entry filtering, root path wrapper normalization,
canonical path wrapper dedupe, and content-access documentation.

The current focus is:

Priority:

- Preserve the command-line tool, install notes, license, and man page
- Keep `run.pl` forwarding arguments without shell command construction
- Keep the wrapper directory owned and non-writable by other users before
  resolving the historical executable
- Reject every non-sticky writable ancestor in the canonical wrapper and
  library directory chains
- Keep `run.pl` building `PERL5LIB` with Perl's configured path separator
- Keep wrapper submodule library paths aligned with `mouse`, `mousex-getopt`,
  and `mousex-nativetraits`
- Keep HTTPS submodule URLs for dependency metadata
- Keep wrapper `PERL5LIB` entries limited to existing local library paths before
  preserving external values
- Remove empty PERL5LIB entries before rebuilding the wrapper environment
- Avoid duplicate local library paths when the environment already includes one
  of the wrapper paths
- Treat trailing slash variants of wrapper-managed local paths as duplicates
- Preserve root path entries while normalizing `PERL5LIB` for duplicate checks
- Treat canonical path variants of wrapper-managed local paths as duplicates
- Execute isolated wrapper handoff tests for arguments and `PERL5LIB`
- Prove interpreter and shell startup variables are scrubbed at the child exec boundary
- Keep the legacy `get_iplayer` script syntax-checkable on the current Perl runtime
- Keep `make lint`, `make test`, `make build`, and `make check` available as
  local verification gates
- Keep hosted syntax, help-output, wrapper, and static-resource validation
  pinned and read-only on Linux with the packaged LWP runtime modules
- Keep security policy visible
- Avoid undocumented behavior around content access or downloads
- Maintain submodule and script structure

Next priorities:

- Document runtime and dependency expectations
- Verify the CLI help path and basic script execution
- Clarify upstream relationship and update policy
- Keep content-access behavior aligned with applicable terms and user controls
- Keep radio bitrate guidance tied to implemented modes without promising availability

Contribution rules:

- One PR = one focused CLI, dependency, documentation, or upstream-sync change.
- Preserve license and attribution files.
- Run `make lint`, `make test`, `make build`, and `make check` before pushing
  wrapper, script, documentation, or ignore-rule changes.
  GitHub Actions should run the same static baseline for pushed changes.
- Do not add credential capture or hidden telemetry.
- Document any behavior that changes content access or storage.
- Preserve wrapper path separator handling when changing local dependency paths.
- Keep submodule library path changes reflected in `run.pl` and the baseline.
- Keep HTTPS submodule URL changes reflected in `.gitmodules` and the baseline.

## Security And Compliance

Canonical security policy and reporting:

- [`SECURITY.md`](SECURITY.md)

Media-access tools should be transparent about what they download, where files
are stored, and which credentials or cookies they use. Do not add hidden
credential collection, shell argument interpolation, or automated access beyond
documented user intent.

## What We Will Not Merge (For Now)

- Hidden credential or cookie collection
- Content-access changes without compliance notes
- License or attribution removals
- Bulk generated downloads in the repository

This list is a roadmap guardrail, not a permanent rule.
Strong user demand and strong technical rationale can change it.
