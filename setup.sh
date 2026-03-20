#!/usr/bin/env bash
set -euo pipefail

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
      # sudo strips SSH_AUTH_SOCK; recover it from the user's processes (Linux /proc).
      if [ -z "${SSH_AUTH_SOCK:-}" ] && [ "$(uname -s)" = "Linux" ]; then
        local _pid _sock
        for _pid in $(pgrep -u "$submod_user" 2>/dev/null); do
          _sock=$(tr '\0' '\n' < "/proc/$_pid/environ" 2>/dev/null \
                  | grep '^SSH_AUTH_SOCK=' | head -1 | cut -d= -f2-)
          if [ -n "$_sock" ] && [ -S "$_sock" ]; then SSH_AUTH_SOCK="$_sock"; break; fi
        done
      fi
      local submod_env=("HOME=$(eval echo "~$submod_user")")
      [ -n "${SSH_AUTH_SOCK:-}" ] && submod_env+=("SSH_AUTH_SOCK=$SSH_AUTH_SOCK")
      sudo -u "$submod_user" env "${submod_env[@]}" \
        git -C "$dotfiles_dir" submodule update --init --recursive \
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
