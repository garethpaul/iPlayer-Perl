# Wrapper Environment Scrub Runtime Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use executing-plans to implement this plan task-by-task.

**Goal:** Prove at runtime that the wrapper removes interpreter and shell startup variables before executing `get_iplayer`.

**Architecture:** Extend the existing fake entrypoint to serialize selected environment values after the wrapper's real `exec`. Assert unset dangerous variables and the fixed system `PATH`, then mutation-test the contract.

**Tech Stack:** Perl 5.26+ taint mode, TAP/Test::More, POSIX shell mutations, Python static baseline, GNU Make.

---

status: completed

### Task 1: Observe the child environment

- Modify `t/run-wrapper.t` to print and assert reviewed environment values.
- Pass hostile startup values through the existing fork/exec helper.
- Run `prove -v t/run-wrapper.t` under default and `0002` umasks.

### Task 2: Make the proof mutation-sensitive

- Modify `tests/hostile-mutations.sh` to remove the scrub operation.
- Keep `scripts/check-baseline.py` synchronized with the runtime fixture.
- Run the hostile mutation suite and verify rejection.

### Task 3: Record and verify

- Update security, agent, README, vision, and changelog guidance.
- Mark this plan completed with exact evidence.
- Run `make lint`, `make test`, `make build`, and `make check`.

## Verification Completed

- The child fixture received hostile values for seven interpreter/shell startup
  variables plus `PATH` and observed every dangerous value unset with
  `PATH=/usr/bin:/bin`.
- All 22 TAP assertions passed under default and collaborative `0002` umasks.
- Ten hostile mutations were rejected, including runtime preservation of
  inherited `IFS`.
- `make lint`, `make test`, `make build`, and `make check` use the same canonical
  baseline and completed successfully.
- No BBC request, credential, download, stream, or external player was used.
