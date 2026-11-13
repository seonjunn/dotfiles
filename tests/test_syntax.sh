#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"

echo "[syntax]"
for f in $(find . -type f \( -name '*.sh' -o -path './bin/*' \) | sort); do
  bash -n "$f"
done
if command -v fish >/dev/null 2>&1; then
  for f in config/fish/functions/*.fish; do
    fish --no-execute "$f"
  done
fi
echo "PASS syntax"
