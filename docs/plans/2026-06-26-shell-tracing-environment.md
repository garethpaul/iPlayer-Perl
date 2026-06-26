# Shell Tracing Environment Scrub

status: completed

## Context

The maintained taint-mode wrapper removed Perl and shell startup-file variables
before executing the historical client, but inherited `SHELLOPTS`, `BASHOPTS`,
and `PS4` remained. Bash imports `SHELLOPTS=xtrace` and applies the inherited
trace prompt, so descendant shell commands could change logging behavior or
expose command arguments despite the wrapper's deterministic environment claim.

## Requirements

- Remove Bash option and tracing prompt state before the real `exec` boundary.
- Prove the executed child observes all reviewed values unset.
- Preserve argument boundaries, fixed `PATH`, validated `PERL5LIB`, and the
  existing wrapper trust model.
- Add a hostile mutation that restores the inherited tracing variables.
- Do not execute live BBC content access or external players.

## Verification Completed

- RED: the 22 TAP assertions failed because the executed child observed
  `SHELLOPTS=xtrace`.
- GREEN: all 22 TAP assertions passed under default and collaborative `0002`
  umasks after the wrapper removed `SHELLOPTS`, `BASHOPTS`, and `PS4`.
- All repository-root and external-directory `make lint`, `make test`,
  `make build`, and `make check` gates passed.
- Eleven hostile mutations were rejected, including restoration of inherited
  shell tracing state.
- Static syntax, documentation, plan, file-shape, help-output, and compressed
  resource contracts passed.
- No BBC request, credential, download, stream, or external player was used.

## Scope Boundaries

- Keep the preserved `get_iplayer` 2.76 client and content-access behavior
  unchanged.
- Do not broaden environment removal without a concrete interpreter or shell
  startup boundary and an executable regression.
