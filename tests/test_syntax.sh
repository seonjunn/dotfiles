#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"

echo "[syntax]"
for f in $(find . -type f \( -name '*.sh' -o -path './bin/*' \) | sort); do
  bash -n "$f"
done
if command -v fish >/dev/null 2>&1; then
  fish --no-execute config/fish/functions/dotpl.fish
fi
echo "PASS syntax"
