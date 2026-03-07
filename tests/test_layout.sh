#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"

echo "[layout]"
assert_dir bootstrap
assert_dir bootstrap/lib
assert_dir bootstrap/ops
assert_dir config
assert_dir bin
assert_not_dir setup
assert_not_dir fish
assert_not_dir claude
assert_not_dir agents
assert_not_dir vim
assert_not_dir tmux
assert_not_dir ipython
assert_not_dir bash
echo "PASS layout"
