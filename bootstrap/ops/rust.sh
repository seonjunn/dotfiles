#!/usr/bin/env bash

run_rust() {
  if [ ! -f "$SETUP_HOME/.cargo/bin/rustup" ]; then
    run "curl -sSf https://sh.rustup.rs | sh -s -- -y"
  fi

  if [ "$DRY_RUN" = false ] && [ -f "$SETUP_HOME/.cargo/env" ]; then
    . "$SETUP_HOME/.cargo/env"
  fi

  run cargo install zoxide --locked
  run cargo install eza
}

verify_rust() {
  [ -f "$SETUP_HOME/.cargo/bin/rustup" ] && command -v zoxide &>/dev/null && command -v eza &>/dev/null
}

declare -A OP_RUST=(
  [name]="rust"
  [category]="installation"
  [deps]="packages"
  [run_fn]="run_rust"
  [verify_fn]="verify_rust"
  [desc]="Rust"
)
register_operation OP_RUST
