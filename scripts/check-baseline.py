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
        "CHANGES.md",
        "INSTALL",
        "LICENSE.txt",
        "Makefile",
        "README",
        "README.md",
        "SECURITY.md",
        "VISION.md",
        "docs/plans/2026-06-08-iplayer-perl-baseline.md",
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

    expect(os.access(str(rel("run.pl")), os.X_OK), "run.pl should be executable")
    expect("use strict;" in run_pl, "run.pl should enable strict")
    expect("use warnings;" in run_pl, "run.pl should enable warnings")
    expect("exec { $command } $command, @ARGV;" in run_pl, "run.pl should exec get_iplayer without a shell")
    expect("`$command`" not in run_pl, "run.pl should not execute a shell command string")
    expect("join(\" \",map" not in run_pl, "run.pl should not quote argv by hand")
    expect("$ENV{PERL5LIB}" in run_pl, "run.pl should preserve PERL5LIB handling")

    legacy_hash_ref = re.compile(r"%\{\s*\$(?:verpid_element|episode_element|series_element)\s*\}\s*->")
    expect(not legacy_hash_ref.search(get_iplayer), "get_iplayer should not use legacy hash-as-reference dereferences")
    expect("my $version = 2.76;" in get_iplayer, "get_iplayer version should remain visible")
    expect("HTTP::Cookies" in get_iplayer, "get_iplayer cookie handling should remain visible for review")
    expect("LWP::UserAgent" in get_iplayer, "get_iplayer network client should remain visible for review")


def check_docs():
    readme = read_text("README.md")
    vision = read_text("VISION.md")
    security = read_text("SECURITY.md")
    changes = read_text("CHANGES.md")
    plan = read_text("docs/plans/2026-06-08-iplayer-perl-baseline.md")
    gitignore = read_text(".gitignore")

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

    expect("scripts/check-baseline.py" in readme, "README should name the baseline checker")
    expect("perl -c" in readme, "README should document Perl syntax verification")
    expect("argument-preserving" in changes, "CHANGES should mention safe argv forwarding")
    expect("modern Perl" in changes, "CHANGES should mention modern Perl compatibility")
    expect("status: completed" in plan, "baseline plan should be marked completed")

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
