#!/usr/bin/env bash

run_ipython() {
  run mkdir -p "$SETUP_HOME/.ipython"
  run rm -rf "$SETUP_HOME/.ipython/profile_default"
  run ln -sf "$SETUP_DOTFILES_DIR/config/ipython/profile_default" "$SETUP_HOME/.ipython/profile_default"
}

verify_ipython() {
  [ "$(readlink "$SETUP_HOME/.ipython/profile_default" 2>/dev/null || true)" = "$SETUP_DOTFILES_DIR/config/ipython/profile_default" ]
}

declare -A OP_IPYTHON=(
  [name]="ipython"
  [category]="configuration"
  [deps]="dotfiles"
  [run_fn]="run_ipython"
  [verify_fn]="verify_ipython"
  [desc]="IPython"
)
register_operation OP_IPYTHON
