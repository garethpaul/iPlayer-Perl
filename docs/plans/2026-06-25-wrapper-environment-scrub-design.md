# Wrapper Environment Scrub Runtime Design

status: approved

## Current State

`run.pl` deletes Perl and shell startup variables and replaces `PATH` before it
loads modules. The Python baseline checks the source text, but the TAP handoff
fixture only reports `PERL5LIB` and arguments. A refactor could preserve the
expected source tokens while accidentally exposing an unsafe value to the
executed client.

## Options

1. **Recommended: observe the child environment.** Extend the fake
   `get_iplayer` fixture to report the reviewed variables, launch the wrapper
   with hostile values, and assert that the child sees them unset and sees the
   fixed `PATH`. This tests the real exec boundary without production changes.
2. **Static checks only.** Lowest cost, but continues proving implementation
   text rather than runtime behavior.
3. **Add a wrapper diagnostic mode.** Easier to inspect, but adds a production
   interface solely for tests and expands the historical wrapper surface.

## Validation

- Run the TAP suite under default and collaborative `0002` umasks.
- Add a hostile mutation that removes environment deletion and require the
  canonical checker to reject it.
- Run all Make gates without invoking BBC services or external media tools.
