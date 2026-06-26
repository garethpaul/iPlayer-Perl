# Security Policy

## Supported Versions

The supported security scope for `iPlayer-Perl` is the current default branch, `master`. Older commits, tags, branches, forks, demos, and generated artifacts are not actively supported unless the repository explicitly marks them as maintained.

Project summary: get_iplayer

## Reporting a Vulnerability

Please report suspected vulnerabilities through GitHub's private vulnerability reporting or by opening a draft GitHub Security Advisory for `garethpaul/iPlayer-Perl` when that option is available. If GitHub does not show a private reporting option for this repository, contact the repository owner through GitHub and avoid posting exploit details publicly until the issue can be assessed.

Do not open a public issue that includes exploit code, secrets, personal data, or detailed reproduction steps for an unpatched vulnerability.

## What to Include

Helpful reports include:

- the affected file, endpoint, permission, dependency, or workflow
- a concise impact statement explaining what an attacker could do
- reproduction steps using test data and accounts you control
- the branch, commit SHA, platform version, device, runtime, or dependency versions used
- logs, screenshots, or proof-of-concept snippets that demonstrate impact without exposing private data

## Project Security Posture

- This repository appears to be a public sample, documentation, or utility project. The active security scope is the code and documentation on the default branch.
- `get_iplayer` is a legacy media-access CLI. Content access, downloads, cookies, credentials, proxy settings, and external player/transcoder commands should stay documented and tied to explicit user options.
- Radio bitrate and proxy guidance must not promise stream availability or
  treat an RTMP endpoint as an HTTP proxy. Network routing and VPN policy remain
  outside the wrapper; users remain responsible for applicable service terms
  and law.
- `run.pl` should forward arguments directly to `get_iplayer` without shell command construction from user input.
- `run.pl` should preserve local dependency lookup using Perl's configured `PERL5LIB` path separator rather than shell-specific string assumptions.
- `run.pl` should only prepend existing local library paths before preserving external `PERL5LIB` entries, remove empty PERL5LIB entries so the launch directory is not added to module lookup, and avoid duplicate local library paths already present in the environment, including trailing slash, root path, and canonical path variants.
- `.gitmodules` should use HTTPS submodule URLs instead of unauthenticated
  `git://` transport.
- Run `make check` after changing Perl scripts, wrapper behavior, documentation, ignore rules, man page handling, or generated help output.
- Wrapper exec tests must preserve arbitrary argument boundaries, existing
  `PERL5LIB` content, and one canonical copy of each local dependency path.
- The executed child must observe `PERLLIB`, `PERL5OPT`, `PERL_USE_UNSAFE_INC`,
  `IFS`, `CDPATH`, `ENV`, `BASH_ENV`, `SHELLOPTS`, `BASHOPTS`, and `PS4`
  unset, with `PATH=/usr/bin:/bin`. This prevents inherited shell tracing state
  from changing or disclosing descendant Bash command execution.
- The pinned Linux workflow installs Ubuntu's packaged LWP runtime modules and
  runs read-only syntax and local help-output checks without initializing
  optional submodules, accessing content, using cookies or credentials,
  downloading media, or invoking external programs.
- The maintained wrapper rejects a symlinked, incorrectly owned, group-writable,
  or world-writable wrapper directory before resolving and executing the
  historical client.
- The wrapper also rejects any non-sticky writable ancestor in the canonical
  directory chain so another user cannot replace the validated directory entry.
- Review found authentication, token, or session-related code paths; changes in those areas should receive security-focused review before merge.
- Review found network clients, sockets, web APIs, or service endpoints; changes in those areas should receive security-focused review before merge.
- Review found mobile permission or privacy-sensitive data handling; changes in those areas should receive security-focused review before merge.
- Review found database, model, query, or persistence-related code; changes in those areas should receive security-focused review before merge.
- No primary dependency manifest was detected in the repository root. If dependencies are added later, include a manifest and prefer reproducible installation instructions.

## Service and API Notes

For web services, APIs, sockets, or scraping workflows, prioritize reports involving authentication bypass, authorization errors, injection, server-side request forgery, unsafe deserialization, credential leakage, data exposure, or denial-of-service conditions. Use test accounts and minimal proof-of-concept traffic only.

## Dependency and Supply Chain Security

Dependency updates should come from trusted package managers and should keep lockfiles in sync when lockfiles exist. Do not commit credentials, private keys, tokens, generated secrets, or machine-local configuration. If a vulnerability depends on a compromised package, typosquatting risk, insecure transitive dependency, or unsafe build step, include the package name, affected version, and the path through which it is used.

## Safe Research Guidelines

Good-faith research is welcome when it stays within these boundaries:

- use only accounts, devices, data, and infrastructure that you own or have explicit permission to test
- avoid destructive actions, persistence, spam, phishing, social engineering, or denial-of-service testing
- minimize access to personal data and stop testing immediately if private data is exposed
- do not exfiltrate secrets or third-party data; report the minimum evidence needed to verify impact
- keep vulnerability details confidential until the maintainer has assessed the report

## Maintainer Response

The maintainer will review complete reports as availability allows, prioritize issues by exploitability and impact, and coordinate a fix or mitigation when the affected code is still maintained. For sample, archived, or educational repositories, the likely remediation may be documentation, dependency updates, or clearly marking unsupported code rather than a production-style patch release.
