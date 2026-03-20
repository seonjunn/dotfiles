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
  run ln -sf "$SETUP_DOTFILES_DIR/config/claude/settings.json" "$SETUP_HOME/.claude/settings.json"
  run rm -rf "$SETUP_HOME/.claude/commands"
  run ln -sf "$SETUP_DOTFILES_DIR/config/claude/commands" "$SETUP_HOME/.claude/commands"
  link_shared_skills "$SETUP_HOME/.claude/skills"
  run rm -rf "$SETUP_HOME/.claude/agents"
  run ln -sf "$SETUP_DOTFILES_DIR/config/claude/agents" "$SETUP_HOME/.claude/agents"
  run bash "$SETUP_DOTFILES_DIR/config/agents/skills/l4l/install.sh"
  run bash "$SETUP_DOTFILES_DIR/config/agents/skills/install-research.sh"
  install_shared_mcp_servers
  register_claude_mcp arxiv -- /bin/sh -c \
    'PATH=$HOME/.local/bin:/opt/homebrew/bin:$PATH exec arxiv-mcp-server'
  register_claude_mcp github \
    -e "GITHUB_PERSONAL_ACCESS_TOKEN=$(awk '/GITHUB_PERSONAL_ACCESS_TOKEN/{print $3}' "$SETUP_HOME/.env")" \
    -- github-mcp-server stdio
  register_claude_mcp sequential-thinking -- npx -y @modelcontextprotocol/server-sequential-thinking
}

verify_claude() {
  command -v claude &>/dev/null \
    && [ "$(readlink "$SETUP_HOME/.claude/CLAUDE.md" 2>/dev/null || true)" = "$SETUP_DOTFILES_DIR/config/claude/CLAUDE.md" ] \
    && [ "$(readlink "$SETUP_HOME/.claude/settings.json" 2>/dev/null || true)" = "$SETUP_DOTFILES_DIR/config/claude/settings.json" ] \
    && [ "$(readlink "$SETUP_HOME/.claude/commands" 2>/dev/null || true)" = "$SETUP_DOTFILES_DIR/config/claude/commands" ] \
    && [ "$(readlink "$SETUP_HOME/.claude/skills" 2>/dev/null || true)" = "$SETUP_DOTFILES_DIR/config/agents/skills" ] \
    && [ "$(readlink "$SETUP_HOME/.claude/agents" 2>/dev/null || true)" = "$SETUP_DOTFILES_DIR/config/claude/agents" ] \
    && python3 -c "
import json, sys
try:
    d = json.load(open('$SETUP_HOME/.claude.json'))
    s = d.get('mcpServers', {})
    assert all(k in s for k in ('arxiv', 'github', 'sequential-thinking'))
except Exception:
    sys.exit(1)
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
