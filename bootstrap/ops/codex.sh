#!/usr/bin/env bash

codex_version() {
  node -p "require('$SETUP_DOTFILES_DIR/nix/packages/codex/package.json').dependencies['@openai/codex']"
}

codex_binary_current() {
  command -v codex &>/dev/null && [ "$(codex --version 2>/dev/null)" = "codex-cli $(codex_version)" ]
}

run_codex() {
  if ! codex_binary_current && ! hm_active; then
    run npm i -g "@openai/codex@$(codex_version)"
  fi

  if ! hm_active; then # Home Manager links these on HM machines
    run mkdir -p "$SETUP_HOME/.codex" "$SETUP_HOME/.agents"
    run ln -sf "$SETUP_DOTFILES_DIR/config/agents/AGENTS.md" "$SETUP_HOME/.codex/AGENTS.md"
    link_shared_skills "$SETUP_HOME/.agents/skills"
  fi
  install_shared_mcp_servers
  if codex mcp --help >/dev/null 2>&1; then
    if ! codex mcp get arxiv >/dev/null 2>&1; then
      run codex mcp add arxiv -- arxiv-mcp-server
    fi
  fi
}

verify_codex() {
  codex_binary_current && { hm_active || {
    [ "$(readlink "$SETUP_HOME/.codex/AGENTS.md" 2>/dev/null || true)" = "$SETUP_DOTFILES_DIR/config/agents/AGENTS.md" ] \
    && [ "$(readlink "$SETUP_HOME/.agents/skills" 2>/dev/null || true)" = "$SETUP_DOTFILES_DIR/config/agents/skills" ]
  }; }
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
