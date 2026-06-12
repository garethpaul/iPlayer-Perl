# Radio Bitrate Guidance

status: completed

## Context

Issue #1 asks how to request higher-quality BBC radio streams and whether an
RTMP endpoint such as `localhost:1935` can be used as a browser-style proxy.
This repository version supports ordered `--radiomode` fallbacks, HTTP proxy
URLs through `--proxy`, and the optional `--partial-proxy` behavior.

## Completed Scope

- Document inspecting advertised radio modes before recording.
- Document an ordered higher-quality AAC mode preference without promising a
  fixed bitrate or geographic availability.
- Distinguish an HTTP proxy URL from an RTMP stream endpoint.
- Explain the supported `--partial-proxy` option and external VPN boundary.
- Extend the static baseline to keep every documented option tied to the Perl
  implementation.
- Mutation-test removal of a documented option or implementation definition.

## Verification

- `make lint`
- `make test`
- `make build`
- `make check`
- `perl -c get_iplayer`
- `git diff --check`
- Mutation results: changing the documented `--radiomode` example or removing
  the implementation's `radiomode|amode` option definition was rejected by
  `scripts/check-baseline.py`.
