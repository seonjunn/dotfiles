#!/usr/bin/env bash

run_node() {
  run "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | PROFILE=/dev/null bash"
  if [ "$DRY_RUN" = false ]; then
    export NVM_DIR="$SETUP_HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  fi
  run "nvm install --lts"
  run "nvm alias default 'lts/*'"

  if [ "$DRY_RUN" = false ] && [ -f "$SETUP_HOME/.nvm/nvm.sh" ]; then
    export NVM_DIR="$SETUP_HOME/.nvm"
    . "$NVM_DIR/nvm.sh"
  fi

  # Create a stable symlink at ~/bin/node pointing to the nvm default Node.
  # This gives tools like openclaw a fixed path that survives nvm upgrades.
  if [ "$DRY_RUN" = false ]; then
    mkdir -p "$SETUP_HOME/bin"
    ln -sf "$(nvm which default)" "$SETUP_HOME/bin/node"
    ln -sf "$(dirname "$(nvm which default)")/npm" "$SETUP_HOME/bin/npm"
    ln -sf "$(dirname "$(nvm which default)")/npx" "$SETUP_HOME/bin/npx"
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
