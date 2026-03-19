#!/usr/bin/env bash
set -euo pipefail

# Auto-accept new SSH host keys non-interactively (e.g. github.com on a fresh
# machine). Does not override if already set.
export GIT_SSH_COMMAND="${GIT_SSH_COMMAND:-ssh -o StrictHostKeyChecking=accept-new}"

SCRIPT_DIR=""
[ -n "${BASH_SOURCE[0]:-}" ] && SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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
    git clone "$REPO_URL" "$dotfiles_dir"
    git -C "$dotfiles_dir" remote set-url origin "$REPO_SSH_URL" || true
    local submod_user="${SUDO_USER:-}"
    if [ -n "$submod_user" ]; then
      chown -R "$submod_user" "$dotfiles_dir"
      sudo -u "$submod_user" git -C "$dotfiles_dir" submodule update --init --recursive \
        || echo "[warn] Submodules not initialized (SSH keys unavailable). Run 'git submodule update --init --recursive' later."
    else
      git -C "$dotfiles_dir" submodule update --init --recursive \
        || echo "[warn] Submodules not initialized. Run 'git submodule update --init --recursive' later."
    fi
    echo "[ ok ] Bootstrap dotfiles repo"
  fi

  exec bash "$dotfiles_dir/bootstrap/setup.sh" "$@"
}

if [ -f "$SCRIPT_DIR/bootstrap/setup.sh" ]; then
  exec bash "$SCRIPT_DIR/bootstrap/setup.sh" "$@"
else
  bootstrap_repo_and_exec "$@"
fi
