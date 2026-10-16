#!/usr/bin/env bash

# For fish the directory is real (it holds fish_variables); config.fish tells who owns it.
hm_manages_fish() { hm_owns "$SETUP_HOME/.config/fish/config.fish"; }
# HM's tmux config lives in ~/.config/tmux, so ~/.tmux.conf must not come back.
hm_manages_tmux() { hm_owns "$SETUP_HOME/.config/tmux/tmux.conf"; }

run_dotfiles() {
  prune_stale_dotfile_symlinks

  if [ ! -d "$SETUP_DOTFILES_DIR/.git" ]; then
    run_as_user git clone https://github.com/seonjunn/dotfiles "$SETUP_DOTFILES_DIR"
    run_as_user git -C "$SETUP_DOTFILES_DIR" remote set-url origin git@github.com:seonjunn/dotfiles.git
    run_as_user git -C "$SETUP_DOTFILES_DIR" submodule update --init --recursive
  fi
  run_as_user git -C "$SETUP_DOTFILES_DIR" config core.hooksPath .githooks

  hm_owns "$SETUP_HOME/.vimrc" || run ln -sf "$SETUP_DOTFILES_DIR/config/vim/.vimrc" "$SETUP_HOME/.vimrc"
  run mkdir -p "$SETUP_HOME/.config"
  if ! hm_manages_fish; then
    run rm -rf "$SETUP_HOME/.config/fish"
    run ln -sf "$SETUP_DOTFILES_DIR/config/fish" "$SETUP_HOME/.config/fish"
  fi
  hm_manages_tmux || run ln -sf "$SETUP_DOTFILES_DIR/config/tmux/.tmux.conf" "$SETUP_HOME/.tmux.conf"
}

verify_dotfiles() {
  [ -d "$SETUP_DOTFILES_DIR/.git" ] \
    && [ "$(as_user git -C "$SETUP_DOTFILES_DIR" config --get core.hooksPath 2>/dev/null || true)" = ".githooks" ] \
    && { hm_owns "$SETUP_HOME/.vimrc" || [ "$(readlink "$SETUP_HOME/.vimrc" 2>/dev/null || true)" = "$SETUP_DOTFILES_DIR/config/vim/.vimrc" ]; } \
    && { hm_manages_fish || [ "$(readlink "$SETUP_HOME/.config/fish" 2>/dev/null || true)" = "$SETUP_DOTFILES_DIR/config/fish" ]; } \
    && { hm_manages_tmux || [ "$(readlink "$SETUP_HOME/.tmux.conf" 2>/dev/null || true)" = "$SETUP_DOTFILES_DIR/config/tmux/.tmux.conf" ]; }
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
