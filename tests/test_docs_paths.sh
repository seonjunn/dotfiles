#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"

echo "[docs-paths]"
assert_file README.md
assert_file CLAUDE.md

# Critical structure paths should be documented correctly.
grep -F 'bootstrap/' CLAUDE.md >/dev/null
grep -F 'config/fish/' CLAUDE.md >/dev/null
grep -F 'config/claude/' CLAUDE.md >/dev/null
grep -F 'config/agents/' CLAUDE.md >/dev/null
grep -F 'bin/' CLAUDE.md >/dev/null

grep -F 'curl -fsSL https://raw.githubusercontent.com/seonjunn/dotfiles/master/setup.sh | bash' README.md >/dev/null
grep -F 'curl -fsSL https://raw.githubusercontent.com/seonjunn/dotfiles/master/setup.sh | sudo bash' README.md >/dev/null

echo "PASS docs-paths"
