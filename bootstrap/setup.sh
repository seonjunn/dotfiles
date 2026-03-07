#!/usr/bin/env bash
if [ -z "${BASH_VERSINFO:-}" ] || [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
  echo "error: Bash 4+ is required (current: ${BASH_VERSION:-unknown})." >&2
  echo "hint: macOS default /bin/bash is 3.2; run with newer bash." >&2
  exit 1
fi

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

bootstrap_repo_and_reexec() {
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

DRY_RUN=false
VERBOSE=false
LIST=false
HELP=false
MODULES=()

for arg in "$@"; do
  case $arg in
    --dry-run) DRY_RUN=true ;;
    --verbose) VERBOSE=true ;;
    --list) LIST=true ;;
    --help|-h) HELP=true ;;
    -*)
      echo "unknown flag: $arg" >&2
      exit 1
      ;;
    *) MODULES+=("$arg") ;;
  esac
done

export DRY_RUN VERBOSE

if [ ! -f "$SCRIPT_DIR/lib/common.sh" ] || [ ! -f "$SCRIPT_DIR/lib/engine.sh" ] || [ ! -d "$SCRIPT_DIR/ops" ]; then
  bootstrap_repo_and_reexec "$@"
fi

source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/engine.sh"

source "$SCRIPT_DIR/ops/groups.sh"
while IFS= read -r -d '' op_file; do
  [ "$op_file" = "$SCRIPT_DIR/ops/groups.sh" ] && continue
  source "$op_file"
done < <(find "$SCRIPT_DIR/ops" -type f -name '*.sh' -print0 | sort -z)

print_help() {
  local i
  echo "Usage: setup.sh [--dry-run] [--verbose] [--list] [MODULE...]"
  echo ""
  echo "Bootstrap a new machine with dotfiles and tools."
  echo "Run via 'sudo bash' to also install system packages and grant passwordless sudo."
  echo ""
  echo "Options:"
  echo "  --dry-run      Print commands without executing them"
  echo "  --verbose      Show command output"
  echo "  --list         List available modules and exit"
  echo "  --help, -h     Show this help message"
  echo ""
  echo "Modules (prefix-matched):"
  for i in "${!SETUP_GROUPS[@]}"; do
    printf '  [%-8s] %s\n' "${SETUP_GROUPS[$i]}" "${SETUP_GROUP_MODULES[$i]}"
  done
}

if [ "$HELP" = true ]; then
  print_help
  exit 0
fi

setup_init_env

if [ "$LIST" = true ]; then
  printf '%s\n' "${SETUP_OPS[@]}"
  exit 0
fi

SETUP_SELECTED_OPS=()
if [ ${#MODULES[@]} -eq 0 ]; then
  SETUP_SELECTED_OPS=("${SETUP_OPS[@]}")
else
  for m in "${MODULES[@]}"; do
    resolved="$(resolve_prefix "$m")"
    collect_with_deps "$resolved"
  done
fi

resolve_execution_order

for op in "${SETUP_ORDERED_OPS[@]}"; do
  execute_operation "$op"
done

run rm -f "$SETUP_DOTFILES_DIR/.setup-needed"

echo ""
echo "Done."
