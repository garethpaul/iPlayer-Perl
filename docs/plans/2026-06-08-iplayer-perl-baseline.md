# iPlayer Perl Baseline Plan

status: completed

## Context

`iPlayer-Perl` preserves a legacy `get_iplayer` Perl command-line utility with
install notes, a GPL license, a compressed man page, and a small wrapper script.
The tool touches content access, local downloads, credentials, cookies, network
requests, and external player/transcoder commands, so repository verification
needs to keep those boundaries explicit.

## Objectives

- Preserve the `get_iplayer` CLI, license, man page, and help output.
- Keep `run.pl` from invoking a shell with quoted user arguments.
- Make the legacy script pass syntax checks under the current Perl runtime.
- Keep downloaded media, local config, cookies, credentials, and generated artifacts out of git.
- Add a reproducible `make check` baseline for Perl syntax, help output, wrapper behavior, docs, and static resource parsing.

## Verification

- `make check`
- `perl -c run.pl`
- `perl -c get_iplayer`
- `git diff --check`
