#!/usr/bin/env bash

setup_init_env() {
  [ "$(uname -s)" = "Linux" ] && export DEBIAN_FRONTEND=noninteractive

  OS=$(uname -s)
  ARCH=$(uname -m)
  export OS ARCH

  TARGET_USER="${SUDO_USER:-${USER:-$(id -un)}}"
  if [ -n "${SUDO_USER:-}" ] && [ "$(id -u)" -eq 0 ]; then
    TARGET_HOME="$(eval echo "~$SUDO_USER")"
  else
    TARGET_HOME="$HOME"
  fi

  SETUP_HOME="$TARGET_HOME"
  SETUP_DOTFILES_DIR="${DOTFILES_DIR:-$SETUP_HOME/.dotfiles}"
  export TARGET_USER TARGET_HOME SETUP_HOME SETUP_DOTFILES_DIR

  [ -d "$SETUP_HOME/.local/bin" ] && export PATH="$SETUP_HOME/.local/bin:$PATH"
  ZB_PREFIX="${ZEROBREW_PREFIX:-/opt/zerobrew/prefix}"
  [ -d "$SETUP_HOME/.zerobrew/bin" ] && export PATH="$SETUP_HOME/.zerobrew/bin:$PATH"
  [ -d "$ZB_PREFIX/bin" ] && export PATH="$ZB_PREFIX/bin:$PATH"

  HAS_SUDO=false
  [ -n "${SUDO_USER:-}" ] && HAS_SUDO=true
  export HAS_SUDO

  SECTION=""
  trap '[ -n "${SECTION:-}" ] && echo "[fail] $SECTION"' ERR
}

run() {
  if [ "$DRY_RUN" = true ]; then
    if [ $# -eq 1 ]; then
      echo "  $1"
    else
      printf ' '
      printf ' %q' "$@"
      printf '\n'
    fi
  elif [ "$VERBOSE" = true ]; then
    if [ $# -eq 1 ]; then
      eval "$1"
    else
      "$@"
    fi
  else
    if [ $# -eq 1 ]; then
      eval "$1" &>/dev/null
    else
      "$@" &>/dev/null
    fi
  fi
}

section() { SECTION="$1"; echo "[....] $1"; }
ok() { echo "[ ok ] $SECTION"; SECTION=""; }
skip() { echo "[skip] $1"; SECTION=""; }

refresh_brew_path() {
  [ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"
  [ -x /usr/local/bin/brew ] && eval "$(/usr/local/bin/brew shellenv)"
}

ensure_brew() {
  if command -v brew &>/dev/null; then
    return 0
  fi

  run "NONINTERACTIVE=1 /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""

  if [ "$DRY_RUN" = false ]; then
    refresh_brew_path
    command -v brew &>/dev/null
  fi
}

has_all_commands() {
  local cmd
  for cmd in "$@"; do
    if ! command -v "$cmd" &>/dev/null; then
      return 1
    fi
  done
  return 0
}

link_shared_skills() {
  local target_dir="$1"
  run rm -rf "$target_dir"
  run ln -sf "$SETUP_DOTFILES_DIR/config/agents/skills" "$target_dir"
}

install_shared_mcp_servers() {
  run uv tool install arxiv-mcp-server
}
