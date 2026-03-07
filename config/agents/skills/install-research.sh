#!/usr/bin/env bash
# install-research.sh — Register research skills as Claude Code slash commands
#
# Usage:
#   bash install-research.sh                          # installs to ~/.claude/commands/
#   bash install-research.sh --project /path/to/proj  # installs to /path/to/proj/.claude/commands/

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/research" && pwd)"
COMMANDS_DIR="$HOME/.claude/commands"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project)
      COMMANDS_DIR="$2/.claude/commands"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

mkdir -p "$COMMANDS_DIR"

while IFS= read -r skill_md; do
  skill_dir="$(dirname "$skill_md")"
  skill_name="$(basename "$skill_dir")"
  command_file="$COMMANDS_DIR/research-${skill_name}.md"

  {
    echo "<!-- resource_dir: $skill_dir -->"
    echo ""
    cat "$skill_md"
  } > "$command_file"

  echo "Installed: $command_file"
done < <(find "$REPO_DIR" -name "skill.md" | sort)

echo ""
echo "Done. Restart Claude Code to pick up new commands."
