#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"

echo "[no-legacy-paths]"

if rg -n '\.dotfiles/(fish|vim|tmux|ipython|claude|agents)' \
  --glob '*.sh' --glob '*.fish' --glob '*.md' \
  bootstrap config README.md CLAUDE.md tests >/tmp/test-legacy-paths.out; then
  echo "FAIL: found legacy .dotfiles/* path references"
  cat /tmp/test-legacy-paths.out
  exit 1
fi

if rg -n '\bsetup/(lib|ops)\b' --glob '*.sh' --glob '*.md' bootstrap README.md CLAUDE.md tests >/tmp/test-legacy-setup-dir.out; then
  echo "FAIL: found legacy setup/ engine path references"
  cat /tmp/test-legacy-setup-dir.out
  exit 1
fi

echo "PASS no-legacy-paths"
