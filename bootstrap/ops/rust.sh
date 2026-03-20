#!/usr/bin/env bash

run_rust() {
  if [ ! -f "$SETUP_HOME/.cargo/bin/rustup" ]; then
    run "HOME='$SETUP_HOME' curl -sSf https://sh.rustup.rs | HOME='$SETUP_HOME' sh -s -- -y"
  fi

  if [ "$DRY_RUN" = false ] && [ -f "$SETUP_HOME/.cargo/env" ]; then
    . "$SETUP_HOME/.cargo/env"
  fi

  run env HOME="$SETUP_HOME" cargo install zoxide --locked
  run env HOME="$SETUP_HOME" cargo install eza
}

verify_rust() {
  [ -f "$SETUP_HOME/.cargo/bin/rustup" ] &&
  [ -f "$SETUP_HOME/.cargo/bin/zoxide" ] &&
  [ -f "$SETUP_HOME/.cargo/bin/eza" ]
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
