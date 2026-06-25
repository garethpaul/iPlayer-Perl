#!/bin/sh
set -eu

ROOT=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd -P)
TMPDIR=${TMPDIR:-/tmp}
WORK=$(mktemp -d "$TMPDIR/iplayer-perl-mutations.XXXXXX")
trap 'rm -rf "$WORK"' EXIT HUP INT TERM

archive_repo() {
  destination=$1
  mkdir -p "$destination"
  tar -C "$ROOT" --exclude .git --exclude __pycache__ -cf - . | tar -x -C "$destination"
}

expect_rejected() {
  name=$1
  directory=$2
  if python3 "$directory/scripts/check-baseline.py" >"$WORK/$name.log" 2>&1; then
    printf 'mutation unexpectedly passed: %s\n' "$name" >&2
    cat "$WORK/$name.log" >&2
    exit 1
  fi
  printf 'rejected mutation: %s\n' "$name"
}

case_dir="$WORK/no-taint"
archive_repo "$case_dir"
sed -i.bak '1s/ -T$//' "$case_dir/run.pl"
rm -f "$case_dir/run.pl.bak"
expect_rejected no-taint "$case_dir"

case_dir="$WORK/caller-relative-make"
archive_repo "$case_dir"
sed -i.bak 's#python3 "$(ROOT)/scripts/check-baseline.py"#python3 scripts/check-baseline.py#' "$case_dir/Makefile"
rm -f "$case_dir/Makefile.bak"
expect_rejected caller-relative-make "$case_dir"

case_dir="$WORK/writable-permissions"
archive_repo "$case_dir"
sed -i.bak 's/contents: read/contents: write/' "$case_dir/.github/workflows/check.yml"
rm -f "$case_dir/.github/workflows/check.yml.bak"
expect_rejected writable-permissions "$case_dir"

case_dir="$WORK/unpinned-action"
archive_repo "$case_dir"
sed -i.bak 's#actions/checkout@[0-9a-f]*#actions/checkout@v7#' "$case_dir/.github/workflows/check.yml"
rm -f "$case_dir/.github/workflows/check.yml.bak"
expect_rejected unpinned-action "$case_dir"

case_dir="$WORK/symlink-entrypoint"
archive_repo "$case_dir"
mv "$case_dir/get_iplayer" "$case_dir/get_iplayer.real"
ln -s get_iplayer.real "$case_dir/get_iplayer"
expect_rejected symlink-entrypoint "$case_dir"

case_dir="$WORK/oversized-source"
archive_repo "$case_dir"
dd if=/dev/zero of="$case_dir/oversized.pl" bs=1024 count=1100 2>/dev/null
expect_rejected oversized-source "$case_dir"

case_dir="$WORK/shell-exec"
archive_repo "$case_dir"
sed -i.bak 's/exec { $command } $command, @arguments;/system("$command @arguments");/' "$case_dir/run.pl"
rm -f "$case_dir/run.pl.bak"
expect_rejected shell-exec "$case_dir"

case_dir="$WORK/untrusted-wrapper-directory"
archive_repo "$case_dir"
sed -i.bak 's/my $safe_bin = secure_directory($Bin);/my $safe_bin = canonical_directory($Bin);/' "$case_dir/run.pl"
rm -f "$case_dir/run.pl.bak"
expect_rejected untrusted-wrapper-directory "$case_dir"

case_dir="$WORK/untrusted-wrapper-ancestor"
archive_repo "$case_dir"
sed -i.bak 's/return if ($ancestor_stat\[2\] & 0022) && !(\$ancestor_stat\[2\] & 01000);/return if 0;/' "$case_dir/run.pl"
rm -f "$case_dir/run.pl.bak"
expect_rejected untrusted-wrapper-ancestor "$case_dir"

printf 'all hostile mutations rejected\n'
