#!/usr/bin/env bash

run_dotfiles() {
  if [ ! -d "$SETUP_DOTFILES_DIR/.git" ]; then
    run git clone --recurse-submodules https://github.com/seonjunn/dotfiles "$SETUP_DOTFILES_DIR"
    run git -C "$SETUP_DOTFILES_DIR" remote set-url origin git@github.com:seonjunn/dotfiles.git
  else
    run git -C "$SETUP_DOTFILES_DIR" submodule update --init --recursive
  fi

  run ln -sf "$SETUP_DOTFILES_DIR/config/vim/.vimrc" "$SETUP_HOME/.vimrc"
  run rm -rf "$SETUP_HOME/.config/fish"
  run ln -sf "$SETUP_DOTFILES_DIR/config/fish" "$SETUP_HOME/.config/fish"
  run ln -sf "$SETUP_DOTFILES_DIR/config/tmux/.tmux.conf" "$SETUP_HOME/.tmux.conf"
}

verify_dotfiles() {
  [ -d "$SETUP_DOTFILES_DIR/.git" ] \
    && [ "$(readlink "$SETUP_HOME/.vimrc" 2>/dev/null || true)" = "$SETUP_DOTFILES_DIR/config/vim/.vimrc" ] \
    && [ "$(readlink "$SETUP_HOME/.config/fish" 2>/dev/null || true)" = "$SETUP_DOTFILES_DIR/config/fish" ] \
    && [ "$(readlink "$SETUP_HOME/.tmux.conf" 2>/dev/null || true)" = "$SETUP_DOTFILES_DIR/config/tmux/.tmux.conf" ]
}

declare -A OP_DOTFILES=(
  [name]="dotfiles"
  [category]="configuration"
  [deps]="git"
  [run_fn]="run_dotfiles"
  [verify_fn]="verify_dotfiles"
  [desc]="Dotfiles"
)
register_operation OP_DOTFILES
