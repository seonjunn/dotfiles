#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

require_bash4() {
  if [ -z "${BASH_VERSINFO:-}" ] || [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
    echo "SKIP: Bash 4+ required (current: ${BASH_VERSION:-unknown})"
    return 1
  fi
  return 0
}

assert_file() {
  [ -f "$1" ] || { echo "FAIL: missing file $1"; return 1; }
}

assert_dir() {
  [ -d "$1" ] || { echo "FAIL: missing dir $1"; return 1; }
}

assert_not_dir() {
  [ ! -d "$1" ] || { echo "FAIL: unexpected dir $1"; return 1; }
}

assert_contains() {
  local text="$1"
  local pat="$2"
  grep -F "$pat" <<<"$text" >/dev/null || { echo "FAIL: expected '$pat'"; return 1; }
}
