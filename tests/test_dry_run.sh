#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"

require_bash4 || exit 0

echo "[dry-run]"
while IFS= read -r op; do
  [ -z "$op" ] && continue
  ./setup.sh --dry-run "$op" >"/tmp/test-op-root-$op.out"
  ./bootstrap/setup.sh --dry-run "$op" >"/tmp/test-op-boot-$op.out"
  diff -u "/tmp/test-op-root-$op.out" "/tmp/test-op-boot-$op.out" >/dev/null
  rm -f "/tmp/test-op-root-$op.out" "/tmp/test-op-boot-$op.out"
done < <(./setup.sh --list)

echo "PASS dry-run"
