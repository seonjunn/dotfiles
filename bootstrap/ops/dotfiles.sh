#!/usr/bin/env bash

# Home Manager owns ~/.config/fish once config.fish is a link into the Nix store.
# Then setup must not replace the directory (it holds fish_variables and HM's files).
hm_manages_fish() {
  case "$(readlink "$SETUP_HOME/.config/fish/config.fish" 2>/dev/null || true)" in
    /nix/store/*) return 0 ;;
  esac
  return 1
}

run_dotfiles() {
  prune_stale_dotfile_symlinks

  if [ ! -d "$SETUP_DOTFILES_DIR/.git" ]; then
    run_as_user git clone https://github.com/seonjunn/dotfiles "$SETUP_DOTFILES_DIR"
    run_as_user git -C "$SETUP_DOTFILES_DIR" remote set-url origin git@github.com:seonjunn/dotfiles.git
    run_as_user git -C "$SETUP_DOTFILES_DIR" submodule update --init --recursive
  fi
  run_as_user git -C "$SETUP_DOTFILES_DIR" config core.hooksPath .githooks

  run ln -sf "$SETUP_DOTFILES_DIR/config/vim/.vimrc" "$SETUP_HOME/.vimrc"
  run mkdir -p "$SETUP_HOME/.config"
  if ! hm_manages_fish; then
    run rm -rf "$SETUP_HOME/.config/fish"
    run ln -sf "$SETUP_DOTFILES_DIR/config/fish" "$SETUP_HOME/.config/fish"
  fi
  run ln -sf "$SETUP_DOTFILES_DIR/config/tmux/.tmux.conf" "$SETUP_HOME/.tmux.conf"
}

verify_dotfiles() {
  [ -d "$SETUP_DOTFILES_DIR/.git" ] \
    && [ "$(as_user git -C "$SETUP_DOTFILES_DIR" config --get core.hooksPath 2>/dev/null || true)" = ".githooks" ] \
    && [ "$(readlink "$SETUP_HOME/.vimrc" 2>/dev/null || true)" = "$SETUP_DOTFILES_DIR/config/vim/.vimrc" ] \
    && { hm_manages_fish || [ "$(readlink "$SETUP_HOME/.config/fish" 2>/dev/null || true)" = "$SETUP_DOTFILES_DIR/config/fish" ]; } \
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
