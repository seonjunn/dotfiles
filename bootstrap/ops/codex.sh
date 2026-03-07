#!/usr/bin/env bash

run_codex() {
  if ! command -v codex &>/dev/null; then
    run npm i -g @openai/codex
  fi

  run mkdir -p "$SETUP_HOME/.codex" "$SETUP_HOME/.agents"
  run ln -sf "$SETUP_DOTFILES_DIR/config/agents/AGENTS.md" "$SETUP_HOME/.codex/AGENTS.md"
  link_shared_skills "$SETUP_HOME/.agents/skills"
  install_shared_mcp_servers
  if codex mcp --help >/dev/null 2>&1; then
    if ! codex mcp get arxiv >/dev/null 2>&1; then
      run codex mcp add arxiv -- arxiv-mcp-server
    fi
  fi
}

verify_codex() {
  command -v codex &>/dev/null \
    && [ "$(readlink "$SETUP_HOME/.codex/AGENTS.md" 2>/dev/null || true)" = "$SETUP_DOTFILES_DIR/config/agents/AGENTS.md" ] \
    && [ "$(readlink "$SETUP_HOME/.agents/skills" 2>/dev/null || true)" = "$SETUP_DOTFILES_DIR/config/agents/skills" ]
}

declare -A OP_CODEX=(
  [name]="codex"
  [category]="configuration"
  [deps]="dotfiles node uv"
  [run_fn]="run_codex"
  [verify_fn]="verify_codex"
  [desc]="Codex"
)
register_operation OP_CODEX
