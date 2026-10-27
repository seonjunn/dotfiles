#!/usr/bin/env bash

ccs_version() {
  node -p "require('$SETUP_DOTFILES_DIR/nix/packages/ccs/package.json').dependencies['@kaitranntt/ccs']"
}

run_ccs() {
  if hm_active; then
    echo "CCS is managed by Home Manager; apply the current Home Manager configuration." >&2
    return 1
  fi
  # The same version as Home Manager. Hooks migrate account data; let the CLI
  # initialize its own state when it is actually used instead.
  run npm install -g --ignore-scripts "@kaitranntt/ccs@$(ccs_version)"
}

verify_ccs() {
  command -v ccs &>/dev/null || return 1
  local scratch output status
  scratch="$(mktemp -d)" || return 1
  # Even --version may initialize CCS state: keep verification out of ~/.ccs.
  output="$(CCS_HOME="$scratch" ccs --version 2>/dev/null)"
  status=$?
  rm -rf "$scratch"
  [ "$status" = 0 ] && printf '%s\n' "$output" | grep -Fxq "CCS (Claude Codex Switch) v$(ccs_version)"
}

declare -A OP_CCS=(
  [name]="ccs"
  [category]="installation"
  [deps]="claude"
  [run_fn]="run_ccs"
  [verify_fn]="verify_ccs"
  [desc]="ccs"
)
register_operation OP_CCS
