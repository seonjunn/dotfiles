#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"

echo "[submodules]"
status="$(git submodule status)"
assert_contains "$status" "config/agents/skills/l4l"
assert_contains "$status" "config/agents/skills/research"
if grep -q '^-' <<<"$status"; then
  echo "FAIL: submodule not initialized"
  exit 1
fi
echo "PASS submodules"
