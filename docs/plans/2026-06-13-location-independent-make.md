# Location-Independent iPlayer Perl Verification

status: in progress

## Context

Absolute Makefile invocations resolve both `scripts/check-baseline.py` and the
`t` test directory relative to the caller instead of the checkout, so the
documented verification aliases fail outside the repository directory.

## Scope

1. Derive the checkout root from the loaded Makefile.
2. Invoke the checker by absolute path and run TAP tests from the checkout.
3. Add exact Makefile, completed-plan, external-run, and guidance contracts.
4. Preserve wrapper argument boundaries, `PERL5LIB` behavior, legacy client
   files, and workflow policy.

## Verification Plan

- Run all four Make gates from the checkout and through an absolute Makefile
  path from a temporary directory.
- Run checker compilation, Perl syntax, TAP tests, and diff checks.
- Reject root-derivation, checker-invocation, TAP-working-directory,
  plan-status, plan-evidence, and documentation mutations independently.
- Inspect intended paths, secret patterns, conflict markers, downloaded media,
  and generated artifacts before commit.

## Risk And Rollback

This changes verification path resolution only. Rollback restores the relative
recipes and removes their checker, plan, and documentation contracts.
