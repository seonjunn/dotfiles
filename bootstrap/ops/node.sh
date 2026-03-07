#!/usr/bin/env bash

run_node() {
  run "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | PROFILE=/dev/null bash"
  if [ "$DRY_RUN" = false ]; then
    export NVM_DIR="$SETUP_HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  fi
  run nvm install --lts
  run nvm alias default lts/*

  if [ "$DRY_RUN" = false ] && [ -f "$SETUP_HOME/.nvm/nvm.sh" ]; then
    export NVM_DIR="$SETUP_HOME/.nvm"
    . "$NVM_DIR/nvm.sh"
  fi
}

verify_node() {
  [ -f "$SETUP_HOME/.nvm/nvm.sh" ]
}

declare -A OP_NODE=(
  [name]="node"
  [category]="installation"
  [deps]="packages"
  [run_fn]="run_node"
  [verify_fn]="verify_node"
  [desc]="Node.js"
)
register_operation OP_NODE
