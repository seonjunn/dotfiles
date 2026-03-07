#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_URL="https://github.com/seonjunn/dotfiles"
REPO_SSH_URL="git@github.com:seonjunn/dotfiles.git"

bootstrap_dotfiles_dir() {
  local bootstrap_home
  if [ -n "${SUDO_USER:-}" ] && [ "$(id -u)" -eq 0 ]; then
    bootstrap_home="$(eval echo "~$SUDO_USER")"
  else
    bootstrap_home="$HOME"
  fi
  printf '%s' "${DOTFILES_DIR:-$bootstrap_home/.dotfiles}"
}

bootstrap_repo_and_exec() {
  local dotfiles_dir
  dotfiles_dir="$(bootstrap_dotfiles_dir)"

  if ! command -v git >/dev/null 2>&1; then
    echo "error: git is required for bootstrap but was not found in PATH." >&2
    exit 1
  fi

  if [ ! -d "$dotfiles_dir/.git" ]; then
    echo "[....] Bootstrap dotfiles repo"
    git clone --recurse-submodules "$REPO_URL" "$dotfiles_dir"
    git -C "$dotfiles_dir" remote set-url origin "$REPO_SSH_URL" || true
    echo "[ ok ] Bootstrap dotfiles repo"
  fi

  exec bash "$dotfiles_dir/bootstrap/setup.sh" "$@"
}

if [ -f "$SCRIPT_DIR/bootstrap/setup.sh" ]; then
  exec bash "$SCRIPT_DIR/bootstrap/setup.sh" "$@"
else
  bootstrap_repo_and_exec "$@"
fi
