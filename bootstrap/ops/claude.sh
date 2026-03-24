#!/usr/bin/env bash

run_claude() {
  if ! command -v claude &>/dev/null; then
    run "curl -fsSL https://claude.ai/install.sh | bash"
    # The installer creates ~/.local/bin/ which may not have been in PATH
    # when setup_init_env ran.
    export PATH="$SETUP_HOME/.local/bin:$PATH"
  fi

  run mkdir -p "$SETUP_HOME/.claude"
  run ln -sf "$SETUP_DOTFILES_DIR/config/claude/CLAUDE.md" "$SETUP_HOME/.claude/CLAUDE.md"

  # settings.json: copy (not symlink) so ~/.claude is never a symlink target
  # inside a git repo, which triggers Claude Code's circular-symlink detection.
  # Remove any existing symlink before copying (cp fails if src and dst resolve to the same file).
  run rm -f "$SETUP_HOME/.claude/settings.json"
  run cp "$SETUP_DOTFILES_DIR/config/claude/settings.json" "$SETUP_HOME/.claude/settings.json"

  # commands/agents/skills: real directories with per-entry symlinks inside.
  # Claude Code only checks top-level ~/.claude/* entries for circular symlinks,
  # so keeping the directories real avoids the false-positive detection.
  run rm -rf "$SETUP_HOME/.claude/commands"
  run mkdir -p "$SETUP_HOME/.claude/commands"
  for f in "$SETUP_DOTFILES_DIR/config/claude/commands/"*; do
    run ln -sf "$f" "$SETUP_HOME/.claude/commands/"
  done

  run rm -rf "$SETUP_HOME/.claude/agents"
  run mkdir -p "$SETUP_HOME/.claude/agents"
  for f in "$SETUP_DOTFILES_DIR/config/claude/agents/"*; do
    run ln -sf "$f" "$SETUP_HOME/.claude/agents/"
  done

  run rm -rf "$SETUP_HOME/.claude/skills"
  run mkdir -p "$SETUP_HOME/.claude/skills"
  for f in "$SETUP_DOTFILES_DIR/config/agents/skills/"*; do
    run ln -sf "$f" "$SETUP_HOME/.claude/skills/"
  done
  run bash "$SETUP_DOTFILES_DIR/config/agents/skills/l4l/install.sh"
  run bash "$SETUP_DOTFILES_DIR/config/agents/skills/install-research.sh"
  install_shared_mcp_servers
  register_claude_mcp arxiv -- /bin/sh -c \
    'PATH=$HOME/.local/bin:/opt/homebrew/bin:$PATH exec uvx arxiv-mcp-server'
  register_claude_mcp github -- /bin/sh -c \
    'GITHUB_PERSONAL_ACCESS_TOKEN=$(awk "/GITHUB_PERSONAL_ACCESS_TOKEN/{print \$4}" "$HOME/.env") PATH=$HOME/.local/bin:/opt/homebrew/bin:$PATH exec github-mcp-server stdio'
  register_claude_mcp sequential-thinking -- npx -y @modelcontextprotocol/server-sequential-thinking
}

verify_claude() {
  command -v claude &>/dev/null \
    && [ "$(readlink "$SETUP_HOME/.claude/CLAUDE.md" 2>/dev/null || true)" = "$SETUP_DOTFILES_DIR/config/claude/CLAUDE.md" ] \
    && [ -f "$SETUP_HOME/.claude/settings.json" ] && ! [ -L "$SETUP_HOME/.claude/settings.json" ] \
    && [ -d "$SETUP_HOME/.claude/commands" ] && ! [ -L "$SETUP_HOME/.claude/commands" ] \
    && [ -d "$SETUP_HOME/.claude/skills" ] && ! [ -L "$SETUP_HOME/.claude/skills" ] \
    && [ -d "$SETUP_HOME/.claude/agents" ] && ! [ -L "$SETUP_HOME/.claude/agents" ] \
    && python3 -c "
import json, sys, glob
required = {'arxiv', 'github', 'sequential-thinking'}
paths = ['$SETUP_HOME/.claude.json'] + glob.glob('$SETUP_HOME/.ccs/instances/*/.claude.json')
for path in paths:
    try:
        s = json.load(open(path)).get('mcpServers', {})
        if not required.issubset(s):
            sys.exit(1)
    except Exception:
        sys.exit(1)
sys.exit(0)
"
}

declare -A OP_CLAUDE=(
  [name]="claude"
  [category]="configuration"
  [deps]="dotfiles node uv"
  [run_fn]="run_claude"
  [verify_fn]="verify_claude"
  [desc]="Claude"
)
register_operation OP_CLAUDE
