#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"

echo "[exec-bits]"
[ -x setup.sh ] || { echo "FAIL: setup.sh must be executable"; exit 1; }
[ -x bootstrap/setup.sh ] || { echo "FAIL: bootstrap/setup.sh must be executable"; exit 1; }
[ -x .githooks/pre-commit ] || { echo "FAIL: .githooks/pre-commit must be executable"; exit 1; }

for f in bin/* tests/run.sh; do
  [ -f "$f" ] || continue
  [ -x "$f" ] || { echo "FAIL: expected executable: $f"; exit 1; }
done

echo "PASS exec-bits"
