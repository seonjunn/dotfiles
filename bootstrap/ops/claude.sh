#!/usr/bin/env bash

run_claude() {
  if ! command -v claude &>/dev/null && ! command -v ccs &>/dev/null; then
    run "curl -fsSL https://claude.ai/install.sh | bash"
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
  register_claude_mcp arxiv /bin/sh -c \
    'PATH=$HOME/.local/bin:/opt/homebrew/bin:$PATH exec arxiv-mcp-server'
  register_claude_mcp github /bin/sh -c \
    'GITHUB_PERSONAL_ACCESS_TOKEN=$(PATH=/opt/homebrew/bin:$PATH gh auth token) PATH=$HOME/.local/bin:/opt/homebrew/bin:$PATH exec github-mcp-server stdio'
}

verify_claude() {
  [ "$(readlink "$SETUP_HOME/.claude/CLAUDE.md" 2>/dev/null || true)" = "$SETUP_DOTFILES_DIR/config/claude/CLAUDE.md" ] \
    && [ "$(readlink "$SETUP_HOME/.claude/settings.json" 2>/dev/null || true)" = "$SETUP_DOTFILES_DIR/config/claude/settings.json" ] \
    && [ "$(readlink "$SETUP_HOME/.claude/commands" 2>/dev/null || true)" = "$SETUP_DOTFILES_DIR/config/claude/commands" ] \
    && [ "$(readlink "$SETUP_HOME/.claude/skills" 2>/dev/null || true)" = "$SETUP_DOTFILES_DIR/config/agents/skills" ] \
    && [ "$(readlink "$SETUP_HOME/.claude/agents" 2>/dev/null || true)" = "$SETUP_DOTFILES_DIR/config/claude/agents" ]
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
