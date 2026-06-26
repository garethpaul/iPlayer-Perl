# AGENTS.md

## Repository purpose

`garethpaul/iPlayer-Perl` packages a Perl wrapper and legacy `get_iplayer`
command-line client with local dependency-path setup.

## Project structure

- `Makefile` - repository verification targets
- `scripts` - baseline checks and helper scripts
- `docs` - plans, notes, and generated README assets
- `man` - checked-in command documentation

## Development commands

- Install dependencies: no repository-specific install command is documented.
- Full baseline: `make check`
- If a command above skips because a platform toolchain is missing, verify on a machine with that SDK before claiming platform behavior is tested.

## Coding conventions

- Language mix noted in the README: Perl (1).

## Testing guidance

- `t/run-wrapper.t` contains 22 TAP assertions for the real wrapper handoff,
  environment, argument, path, directory, and entrypoint boundaries.
- `tests/hostile-mutations.sh` must reject all eleven reviewed guardrail
  mutations before a wrapper change is handed off.
- Start with the narrowest relevant test or Make target, then run `make check` before handing off if the change is not documentation-only.
- Keep README verification notes in sync when commands, fixtures, or supported toolchains change.

## PR / change guidance

- Keep diffs focused on the requested repository and avoid unrelated modernization or formatting churn.
- Preserve public APIs, sample behavior, file formats, and documented environment variables unless the task explicitly changes them.
- Update tests, README notes, or docs/plans when behavior, security posture, or validation commands change.
- Call out skipped platform validation, legacy toolchain assumptions, and any risky files touched in the final summary.

## Safety and gotchas

- No required secret or credential file was identified in the repository scan. If you add integrations later, keep secrets out of git.
- Do not commit cookies, credentials, private keys, proxy secrets, generated download history, local preference files, downloaded media, or generated subtitles.
- Keep credential and cookie usage visible, documented, and tied to explicit user options. Do not add hidden collection, telemetry, or background content access.
- Wrapper changes must preserve argument boundaries and avoid shell command construction from user input.
- Runtime wrapper tests must prove interpreter/shell startup variables are
  absent from the executed child and `PATH` remains `/usr/bin:/bin`.
- Keep inherited shell tracing state (`SHELLOPTS`, `BASHOPTS`, and `PS4`) out of
  the executed child.
- Wrapper and library paths must reject non-sticky writable ancestors, not only
  unsafe permissions on the final directory.
- Downloaded media and generated artifacts should remain local and ignored unless explicitly documented for a fixture or test.
- Run `make lint`, `make test`, `make build`, and `make check` before pushing changes to `run.pl`, `get_iplayer`, docs, ignore rules, or generated help/manpage handling.

## Agent workflow

1. Inspect the README, Makefile, manifests, and the files directly related to the request.
2. Make the smallest source or docs change that satisfies the task; avoid generated, vendored, or local-environment files unless required.
3. Run the narrowest useful validation first, then `make check` or the documented package/platform gate when available.
4. If a required SDK, service credential, or external runtime is unavailable, record the skipped command and why.
5. Summarize changed files, commands run, and remaining risks or follow-up validation.
