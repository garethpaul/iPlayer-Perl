# Hosted Perl Validation

status: completed

## Context

The repository has executable checks for Perl syntax, versioned help output,
wrapper argument forwarding, `PERL5LIB` behavior, documentation, and static
resources, but no current hosted validation.

## Priorities

1. Run the canonical `make check` gate on a current Linux runner.
2. Pin third-party actions and Python while installing the packaged LWP module
   stack required by the legacy script on the runner's system Perl.
3. Enforce a read-only, bounded workflow contract from the baseline checker.
4. Keep content access, cookies, downloads, submodule initialization, and
   external player or transcoder execution outside CI.

## Implementation Units

### Workflow And Checker

Files:

- `.github/workflows/check.yml`
- `scripts/check-baseline.py`

Add push, pull-request, and manual triggers; read-only permissions; concurrency
cancellation; a bounded `ubuntu-24.04` job; commit-pinned checkout and Python
setup; Ubuntu's `libwww-perl` package; and `make check`. Require those
properties from the baseline.

### Documentation

Files:

- `README.md`
- `VISION.md`
- `SECURITY.md`
- `CHANGES.md`
- `docs/plans/2026-06-10-hosted-perl-validation.md`

Document hosted syntax and help-output validation without implying media or
service integration coverage.

## Verification

- `python3 -m py_compile scripts/check-baseline.py`
- `make lint`
- `make test`
- `make build`
- `make check`
- workflow YAML parse
- `git diff --check`
- successful hosted Linux `Check` workflow for the pushed commit

## Boundaries

- Do not provide cookies, credentials, proxy configuration, or download paths.
- Do not initialize optional dependency submodules or invoke runtime
  content-access or media tools.
