#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for t in "$DIR"/test_*.sh; do
  echo "==> $(basename "$t")"
  bash "$t"
done

echo "All repo health tests passed."
