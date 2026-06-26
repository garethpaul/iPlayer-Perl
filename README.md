# iPlayer-Perl

<!-- README-OVERVIEW-IMAGE -->
![Project overview](docs/readme-overview.svg)

## Overview

`garethpaul/iPlayer-Perl` preserves a historical `get_iplayer` 2.76 client and
its local Perl wrapper. The vendored client dates from 2010, is unsupported,
and is not expected to provide working BBC search, download, or streaming
functionality today.

Its BBC iPlayer feed, playlist, RDF, media-selector, mobile, and schedule
contracts have been retired or removed. For a maintained client, use the
current [`get-iplayer/get_iplayer`](https://github.com/get-iplayer/get_iplayer)
project; the corresponding modern release for this repository review is
[`v3.36`](https://github.com/get-iplayer/get_iplayer/releases/tag/v3.36).

This README is based on the checked-in source, manifests, scripts, and repository metadata on the `master` branch. The project language mix found during review was: Perl (1).

## Repository Contents

- `CHANGES.md` - recent maintenance changes
- `.github/workflows/check.yml` - CI baseline that runs the static Make gate
- `Makefile` - local static verification entry point
- `README.md` - project overview and local usage notes
- `README`
- `get_iplayer` - historical, unsupported version 2.76 command-line client
- `INSTALL` - project installation notes
- `run.pl` - Perl script or command wrapper
- `scripts/check-baseline.py` - static Perl/content-access baseline checks
- `SECURITY.md` - security reporting and disclosure guidance
- `VISION.md` - project direction and maintenance guardrails

Additional scan context:

- Source directories: no top-level source directories detected
- Dependency and build manifests: INSTALL
- Entry points or build surfaces: `make lint`, `make test`, `make build`, `make check`, get_iplayer, run.pl
- Test files: `t/run-wrapper.t` contains 21 TAP wrapper tests, and
  `tests/hostile-mutations.sh` verifies nine rejected maintenance mutations

## Getting Started

### Prerequisites

- Git
- Perl 5.26 or newer for the maintained wrapper checks
- Perl HTML/HTTP/LWP/URI modules used by the vendored client. On Ubuntu, CI
  provides these with `libwww-perl`; other platforms may package them
  separately.
- Python 3 for static verification with `make lint`, `make test`, `make build`, and `make check`

### Setup

```bash
git clone https://github.com/garethpaul/iPlayer-Perl.git
cd iPlayer-Perl
make lint
make test
make build
make check
```

The setup commands above validate the historical snapshot and maintained
wrapper; they do not restore the retired BBC service contracts. Install the
maintained upstream project instead for current BBC iPlayer or BBC Sounds use.

## Running or Using the Project

- `./get_iplayer --help` exposes the historical 2.76 command-line surface for
  inspection only. Passing syntax and help checks does not establish working
  BBC content access.
- Use `./run.pl --help` when exercising the wrapper. Execute it directly with Perl 5.26 or newer; its taint-mode launcher forwards arguments without a shell, rejects unsafe entrypoints and wrapper directories, scrubs interpreter and shell startup variables, fixes `PATH`, and preserves only absolute, non-symlinked, non-writable `PERL5LIB` directories after canonical deduplication. Existing local library paths for `mouse`, `mousex-getopt`, and `mousex-nativetraits` remain first when their directories pass the same validation.
- `.gitmodules` retains three HTTPS mirror entries as legacy dependency-path
  metadata, but this tree contains no pinned submodule gitlinks. Running
  `git submodule update` therefore does not install those dependencies.
- This tool can download or stream media, use cookies or credentials, and invoke external players/transcoders depending on user-supplied options. Keep content access explicit and user-controlled.
- The legacy [`README`](README) documents radio mode inspection, ordered
  `--radiomode` preferences, and HTTP `--proxy`/`--partial-proxy` usage. It does
  not guarantee a bitrate or geographic availability, and an RTMP endpoint is
  not an HTTP proxy.

## Testing and Verification

Pinned `ubuntu-24.04` GitHub Actions installs Ubuntu's `libwww-perl` runtime
modules and runs `make check` with system Perl and Python 3.12. It validates
syntax, versioned help output, wrapper behavior, and static resources without
initializing optional submodules, accessing content, using cookies or
credentials, downloading media, or invoking external players.

- `make lint`, `make test`, `make build`, and `make check` run `scripts/check-baseline.py`, which validates Perl syntax with `perl -c`, verifies help output, parses the compressed man page and SVG overview, checks safe wrapper argument forwarding, empty PERL5LIB entry filtering, existing local library paths, local submodule library paths, duplicate local library paths including trailing slash, root path, and canonical path variants, HTTPS submodule URLs, and `PERL5LIB` path separator handling, and enforces documentation guardrails.
- The same gate runs all 22 TAP tests in `t/run-wrapper.t`, executing the
  wrapper against a temporary fake `get_iplayer` to verify exact argument
  forwarding, validated `PERL5LIB` handling, runtime environment scrubbing, taint-safe startup, and rejection
  of unsafe directories and non-sticky writable ancestors plus unsafe or
  oversized entrypoints.
- `tests/hostile-mutations.sh` additionally verifies that ten changes which
  weaken wrapper, Make, workflow, or entrypoint guardrails are rejected.
- The `lint`, `test`, and `build` targets intentionally alias the static
  baseline so the standard local gate commands stay available while preserving
  the same Perl syntax and wrapper checks as `make check`.
- `perl -c run.pl`
- `perl -c get_iplayer`
- GitHub Actions runs the static `make check` gate through
  `.github/workflows/check.yml` on pushes and pull requests.

When the required SDK or runtime is unavailable, use static checks and source review first, then verify on a machine that has the matching platform toolchain.

## Configuration and Secrets

- No required secret or credential file was identified in the repository scan. If you add integrations later, keep secrets out of git.
- Do not commit cookies, credentials, private keys, proxy secrets, generated download history, local preference files, downloaded media, or generated subtitles.

## Security and Privacy Notes

- Review changes touching authentication or token handling; examples from the scan include get_iplayer.
- Keep credential and cookie usage visible, documented, and tied to explicit user options. Do not add hidden collection, telemetry, or background content access.
- Review changes touching network requests, sockets, or service endpoints; examples from the scan include get_iplayer.
- Wrapper changes must preserve argument boundaries and avoid shell command construction from user input.
- Review changes touching file, media, JSON, XML, CSV, OCR, or data parsing; examples from the scan include get_iplayer.
- Downloaded media and generated artifacts should remain local and ignored unless explicitly documented for a fixture or test.

## Maintenance Notes

- Run `make lint`, `make test`, `make build`, and `make check` before pushing changes to `run.pl`, `get_iplayer`, docs, ignore rules, or generated help/manpage handling.
- The same gates may be invoked through an absolute Makefile path from another
  directory; verification resolves the checker and TAP tests relative to the
  checkout.
- See `SECURITY.md` for vulnerability reporting and safe research guidance.
- See `VISION.md` for project direction and contribution guardrails.
- See `docs/plans/2026-06-10-ci-baseline.md` for the lightweight CI baseline.
- See `docs/plans/2026-06-09-make-gate-aliases.md` for the local gate alias guardrail.

## Contributing

Keep changes small and tied to the project that is already present in this repository. For code changes, document the toolchain used, avoid committing generated dependency directories or local configuration, and update this README when setup or verification steps change.
