#!/usr/bin/env bash

run_uv() {
  run "curl -LsSf https://astral.sh/uv/install.sh | sh"
  if [ "$DRY_RUN" = false ]; then
    export PATH="$SETUP_HOME/.local/bin:$PATH"
  fi
}

verify_uv() {
  command -v uv &>/dev/null || [ -f "$SETUP_HOME/.local/bin/uv" ]
}

declare -A OP_UV=(
  [name]="uv"
  [category]="installation"
  [deps]="packages"
  [run_fn]="run_uv"
  [verify_fn]="verify_uv"
  [desc]="uv"
)
register_operation OP_UV
