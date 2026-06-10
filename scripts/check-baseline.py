#!/usr/bin/env python3
"""Static baseline checks for the legacy get_iplayer Perl repository."""

from __future__ import print_function

import gzip
import os
import re
import shutil
import subprocess
import sys
import xml.etree.ElementTree as ET
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
FAILURES = []


def rel(path):
    return ROOT / path


def expect(condition, message):
    if not condition:
        FAILURES.append(message)


def read_text(path):
    target = rel(path)
    expect(target.exists(), "{} is missing".format(path))
    if not target.exists():
        return ""
    return target.read_text(encoding="utf-8", errors="replace")


def run_command(args):
    return subprocess.run(
        args,
        cwd=str(ROOT),
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
    )


def check_required_files():
    required = [
        ".gitignore",
        ".github/workflows/check.yml",
        "CHANGES.md",
        "INSTALL",
        "LICENSE.txt",
        "Makefile",
        "README",
        "README.md",
        "SECURITY.md",
        "VISION.md",
        ".gitmodules",
        "docs/plans/2026-06-08-iplayer-perl-baseline.md",
        "docs/plans/2026-06-08-perl5lib-path-separator.md",
        "docs/plans/2026-06-08-existing-wrapper-lib-paths.md",
        "docs/plans/2026-06-08-wrapper-submodule-lib-paths.md",
        "docs/plans/2026-06-09-https-submodule-urls.md",
        "docs/plans/2026-06-09-make-gate-aliases.md",
        "docs/plans/2026-06-09-perl5lib-dedupe.md",
        "docs/plans/2026-06-09-perl5lib-trailing-slash-dedupe.md",
        "docs/plans/2026-06-09-perl5lib-canonical-dedupe.md",
        "docs/plans/2026-06-10-perl5lib-root-path-normalization.md",
        "docs/plans/2026-06-10-hosted-perl-validation.md",
        "docs/readme-overview.svg",
        "get_iplayer",
        "man/get_iplayer.1.gz",
        "run.pl",
        "scripts/check-baseline.py",
    ]

    for path in required:
        expect(rel(path).exists(), "{} is missing".format(path))


def check_static_resources():
    try:
        ET.parse(str(rel("docs/readme-overview.svg")))
    except ET.ParseError as exc:
        FAILURES.append("docs/readme-overview.svg is not valid XML: {}".format(exc))

    try:
        with gzip.open(str(rel("man/get_iplayer.1.gz")), "rt", encoding="utf-8", errors="replace") as handle:
            man_text = handle.read()
        expect("get_iplayer" in man_text, "man page should document get_iplayer")
        expect(".SH SYNOPSIS" in man_text, "man page should document command synopsis")
        expect(".SH \"OPTIONS\"" in man_text, "man page should document command options")
    except OSError as exc:
        FAILURES.append("man/get_iplayer.1.gz is not readable gzip data: {}".format(exc))

    license_text = read_text("LICENSE.txt")
    expect("GNU GENERAL PUBLIC LICENSE" in license_text, "LICENSE.txt should preserve GPL terms")


def check_perl_runtime():
    for script in ("run.pl", "get_iplayer"):
        result = run_command(["perl", "-c", script])
        expect(result.returncode == 0, "{} should pass perl -c: {}".format(script, result.stdout.strip()))

    for command in (["./get_iplayer", "--help"], ["./run.pl", "--help"]):
        result = run_command(command)
        output = result.stdout
        expect("get_iplayer v2.76" in output, "{} should print versioned help".format(command[0]))
        expect("Usage" in output, "{} should print usage help".format(command[0]))
        expect("Recording Options" in output, "{} should print recording options".format(command[0]))


def check_wrapper_guardrails():
    run_pl = read_text("run.pl")
    get_iplayer = read_text("get_iplayer")
    gitmodules = read_text(".gitmodules")

    expect(os.access(str(rel("run.pl")), os.X_OK), "run.pl should be executable")
    expect("use strict;" in run_pl, "run.pl should enable strict")
    expect("use warnings;" in run_pl, "run.pl should enable warnings")
    expect("use Config qw(%Config);" in run_pl, "run.pl should use Perl configuration for path separators")
    expect("use Cwd qw(abs_path);" in run_pl, "run.pl should use canonical paths for duplicate checks")
    expect("$Config{path_sep}" in run_pl, "run.pl should read the configured PERL5LIB path separator")
    for local_lib in ("deps/mouse/lib", "deps/mousex-getopt/lib", "deps/mousex-nativetraits/lib"):
        expect(local_lib in run_pl, "run.pl should include local submodule library path {}".format(local_lib))
    expect("sub normalized_path_entry" in run_pl and
           "return $path if $path =~ m{\\A(?:[A-Za-z]:)?[\\\\/]+\\z};" in run_pl and
           "$path =~ s{[\\\\/]+\\z}{};" in run_pl,
           "run.pl should normalize path entries before duplicate comparison while preserving root path entries")
    expect("sub comparable_path_entry" in run_pl and "abs_path($normalized_path)" in run_pl,
           "run.pl should compare existing path entries by canonical path when possible")
    expect("my %existing_perl5lib_entries = ();" in run_pl and
           "map { comparable_path_entry($_) => 1 } split /\\Q$path_separator\\E/" in run_pl,
           "run.pl should parse existing PERL5LIB entries with the configured path separator")
    expect("my @perl5lib_entries = grep { -d $_ && !$existing_perl5lib_entries{comparable_path_entry($_)} } @local_libs;" in run_pl,
           "run.pl should only prepend existing local library paths that are not already in PERL5LIB after canonical comparison")
    expect("if (@perl5lib_entries)" in run_pl and "$ENV{PERL5LIB} = join $path_separator, @perl5lib_entries;" in run_pl,
           "run.pl should avoid creating an empty PERL5LIB when no local or existing paths are available")
    expect('join ":"' not in run_pl, "run.pl should not hardcode Unix PERL5LIB separators")
    expect("exec { $command } $command, @ARGV;" in run_pl, "run.pl should exec get_iplayer without a shell")
    expect("`$command`" not in run_pl, "run.pl should not execute a shell command string")
    expect("join(\" \",map" not in run_pl, "run.pl should not quote argv by hand")
    expect("$ENV{PERL5LIB}" in run_pl, "run.pl should preserve PERL5LIB handling")

    legacy_hash_ref = re.compile(r"%\{\s*\$(?:verpid_element|episode_element|series_element)\s*\}\s*->")
    expect(not legacy_hash_ref.search(get_iplayer), "get_iplayer should not use legacy hash-as-reference dereferences")
    expect("ref$data" not in get_iplayer and "ref$prog" not in get_iplayer and "ref$rdf" not in get_iplayer,
           "get_iplayer should keep modern Perl-compatible ref spacing")
    expect("my $version = 2.76;" in get_iplayer, "get_iplayer version should remain visible")
    expect("HTTP::Cookies" in get_iplayer, "get_iplayer cookie handling should remain visible for review")
    expect("LWP::UserAgent" in get_iplayer, "get_iplayer network client should remain visible for review")
    expect("git://" not in gitmodules, ".gitmodules should not use unauthenticated git:// submodule URLs")
    for submodule_url in (
        "https://github.com/gfx/p5-Mouse.git",
        "https://github.com/gfx/mousex-getopt.git",
        "https://github.com/gfx/p5-MouseX-NativeTraits.git",
    ):
        expect(submodule_url in gitmodules, ".gitmodules should use HTTPS submodule URL {}".format(submodule_url))


def check_docs():
    readme = read_text("README.md")
    vision = read_text("VISION.md")
    security = read_text("SECURITY.md")
    changes = read_text("CHANGES.md")
    plan = read_text("docs/plans/2026-06-08-iplayer-perl-baseline.md")
    path_plan = read_text("docs/plans/2026-06-08-perl5lib-path-separator.md")
    existing_lib_plan = read_text("docs/plans/2026-06-08-existing-wrapper-lib-paths.md")
    submodule_lib_plan = read_text("docs/plans/2026-06-08-wrapper-submodule-lib-paths.md")
    https_submodule_plan = read_text("docs/plans/2026-06-09-https-submodule-urls.md")
    make_gates_plan = read_text("docs/plans/2026-06-09-make-gate-aliases.md")
    perl5lib_dedupe_plan = read_text("docs/plans/2026-06-09-perl5lib-dedupe.md")
    trailing_slash_dedupe_plan = read_text("docs/plans/2026-06-09-perl5lib-trailing-slash-dedupe.md")
    canonical_dedupe_plan = read_text("docs/plans/2026-06-09-perl5lib-canonical-dedupe.md")
    root_path_plan = read_text("docs/plans/2026-06-10-perl5lib-root-path-normalization.md")
    hosted_validation_plan = read_text("docs/plans/2026-06-10-hosted-perl-validation.md")
    workflow = read_text(".github/workflows/check.yml")
    gitignore = read_text(".gitignore")
    makefile = read_text("Makefile")

    expect(".PHONY: build check lint test" in makefile and "lint test build: check" in makefile,
           "Makefile should expose lint, test, build, and check verification gates")

    for text_name, text in (
        ("README.md", readme),
        ("VISION.md", vision),
        ("SECURITY.md", security),
    ):
        lowered = text.lower()
        expect("make check" in lowered, "{} should document the static verification command".format(text_name))
        expect("content access" in lowered or "content-access" in lowered, "{} should document content-access boundaries".format(text_name))
        expect("credential" in lowered or "cookie" in lowered, "{} should document credential or cookie handling".format(text_name))
        expect("download" in lowered, "{} should document local download behavior".format(text_name))
        expect("trailing slash" in lowered, "{} should document trailing slash PERL5LIB dedupe".format(text_name))
        expect("canonical path" in lowered, "{} should document canonical path PERL5LIB dedupe".format(text_name))
        expect("root path" in lowered, "{} should document root path PERL5LIB normalization".format(text_name))

    expect("make lint" in readme and "make test" in readme and "make build" in readme,
           "README should document the standard local verification gates")
    expect("make lint" in vision and "make test" in vision and "make build" in vision,
           "VISION should document the standard local verification gates")
    expect("make lint" in changes and "make test" in changes and "make build" in changes,
           "CHANGES should mention the standard local verification gates")
    expect("scripts/check-baseline.py" in readme, "README should name the baseline checker")
    expect("perl -c" in readme, "README should document Perl syntax verification")
    expect("path separator" in readme.lower() and "path separator" in vision.lower() and "path separator" in security.lower(),
           "docs should describe PERL5LIB path separator handling")
    expect("existing local library paths" in readme.lower() and
           "existing local library paths" in vision.lower() and
           "existing local library paths" in security.lower(),
           "docs should describe filtering missing wrapper library paths")
    expect("mousex-getopt" in readme.lower() and "mousex-getopt" in vision.lower(),
           "docs should describe wrapper submodule library path alignment")
    expect("https submodule" in readme.lower() and "https submodule" in vision.lower() and "https submodule" in security.lower(),
           "docs should describe HTTPS submodule URL handling")
    expect("duplicate local library paths" in readme.lower() and
           "duplicate local library paths" in vision.lower() and
           "duplicate local library paths" in security.lower(),
           "docs should describe duplicate local library path handling")
    expect("canonical path" in changes.lower(), "CHANGES should mention canonical path PERL5LIB dedupe")
    expect("root path" in changes.lower(), "CHANGES should mention root path PERL5LIB normalization")
    expect("trailing slash" in changes.lower(), "CHANGES should mention trailing slash PERL5LIB dedupe")
    expect("argument-preserving" in changes, "CHANGES should mention safe argv forwarding")
    expect("`PERL5LIB` path separator" in changes, "CHANGES should mention PERL5LIB path separator handling")
    expect("mousex-getopt" in changes.lower(), "CHANGES should mention MouseX::Getopt wrapper path handling")
    expect("existing local library paths" in changes.lower(), "CHANGES should mention existing local library path filtering")
    expect("HTTPS submodule" in changes, "CHANGES should mention HTTPS submodule URL handling")
    expect("duplicate local library paths" in changes.lower(), "CHANGES should mention duplicate PERL5LIB path handling")
    expect("modern Perl" in changes, "CHANGES should mention modern Perl compatibility")
    expect("status: completed" in plan, "baseline plan should be marked completed")
    expect("status: completed" in path_plan, "PERL5LIB path separator plan should be marked completed")
    expect("status: completed" in existing_lib_plan, "existing wrapper lib path plan should be marked completed")
    expect("status: completed" in submodule_lib_plan, "wrapper submodule lib path plan should be marked completed")
    expect("status: completed" in https_submodule_plan, "HTTPS submodule URL plan should be marked completed")
    expect("status: completed" in make_gates_plan, "make gate aliases plan should be marked completed")
    expect("status: completed" in perl5lib_dedupe_plan, "PERL5LIB dedupe plan should be marked completed")
    expect("status: completed" in trailing_slash_dedupe_plan,
           "PERL5LIB trailing slash dedupe plan should be marked completed")
    expect("status: completed" in canonical_dedupe_plan,
           "PERL5LIB canonical path dedupe plan should be marked completed")
    expect("status: completed" in root_path_plan,
           "PERL5LIB root path normalization plan should be marked completed")
    expect("status: completed" in hosted_validation_plan and "make check" in hosted_validation_plan,
           "hosted Perl validation plan should be marked completed")
    expect("permissions:\n  contents: read" in workflow and "cancel-in-progress: true" in workflow and
           "runs-on: ubuntu-24.04" in workflow and "timeout-minutes: 10" in workflow and
           "actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10" in workflow and
           "actions/setup-python@a309ff8b426b58ec0e2a45f0f869d46889d02405" in workflow and
           'python-version: "3.12"' in workflow and "run: make check" in workflow,
           "Check workflow should stay pinned, read-only, and bounded")

    for pattern in (".env", ".env.*", "downloads/", "*.mp4", "*.mp3", "*.m4a", "*.flv", "__pycache__/", "*.pyc"):
        expect(pattern in gitignore, ".gitignore should keep {} out of git".format(pattern))


def main():
    check_required_files()
    check_static_resources()
    check_perl_runtime()
    check_wrapper_guardrails()
    check_docs()

    if shutil.which("perl"):
        print("perl available; syntax and help-output checks completed.")
    else:
        print("perl unavailable; static text checks only.")

    if FAILURES:
        print("Static baseline failed:")
        for failure in FAILURES:
            print("- {}".format(failure))
        return 1

    print("Static baseline passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
