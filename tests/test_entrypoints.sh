#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"

require_bash4 || exit 0

echo "[entrypoints]"
root_help="$(./setup.sh --help)"
boot_help="$(./bootstrap/setup.sh --help)"
assert_contains "$root_help" "Usage: setup.sh"
assert_contains "$boot_help" "Usage: setup.sh"

diff -u <(./setup.sh --list) <(./bootstrap/setup.sh --list) >/dev/null

tmp_root="/tmp/test-setup-root-$$.sh"
cp ./setup.sh "$tmp_root"
DOTFILES_DIR="$PWD" bash "$tmp_root" --list >/tmp/test-setup-root-list.out
diff -u /tmp/test-setup-root-list.out <(./setup.sh --list) >/dev/null
rm -f "$tmp_root" /tmp/test-setup-root-list.out

echo "PASS entrypoints"
