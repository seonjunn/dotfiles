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
  NVM_DIR="${NVM_DIR:-$SETUP_HOME/.nvm}"
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  export NVM_DIR
  [ -f "$SETUP_HOME/.cargo/env" ] && . "$SETUP_HOME/.cargo/env"

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
      eval "$1" >/dev/null
    else
      "$@" >/dev/null
    fi
  fi
}

# Like run, but executes as the target (non-root) user when invoked via sudo.
run_as_user() {
  if [ -n "${SUDO_USER:-}" ] && [ "$(id -u)" -eq 0 ]; then
    run sudo -u "$TARGET_USER" "$@"
  else
    run "$@"
  fi
}

# Run a command as the target user without dry-run/verbose wrapping.
# Used for inline subshell calls (e.g. in verify functions).
as_user() {
  if [ -n "${SUDO_USER:-}" ] && [ "$(id -u)" -eq 0 ]; then
    sudo -u "$TARGET_USER" "$@"
  else
    "$@"
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

prune_stale_dotfile_symlinks() {
  local scan_dirs=(
    "$SETUP_HOME"
    "$SETUP_HOME/.config"
    "$SETUP_HOME/.ipython"
    "$SETUP_HOME/.claude"
    "$SETUP_HOME/.codex"
    "$SETUP_HOME/.agents"
  )
  local dir link target
  for dir in "${scan_dirs[@]}"; do
    [ -d "$dir" ] || continue
    while IFS= read -r -d '' link; do
      target="$(readlink "$link")"
      if [[ "$target" == "$SETUP_DOTFILES_DIR"* ]] && [ ! -e "$target" ]; then
        echo "[prune] Removing stale symlink: $link -> $target"
        rm -f "$link"
      fi
    done < <(find "$dir" -maxdepth 1 -type l -print0 2>/dev/null)
  done
}

link_shared_skills() {
  local target_dir="$1"
  run rm -rf "$target_dir"
  run ln -sf "$SETUP_DOTFILES_DIR/config/agents/skills" "$target_dir"
}

install_github_mcp_server_linux() {
  local dest="$SETUP_HOME/.local/bin/github-mcp-server"
  local api_url="https://api.github.com/repos/github/github-mcp-server/releases/latest"
  local arch
  case "$ARCH" in
    x86_64)  arch="x86_64" ;;
    aarch64) arch="arm64" ;;
    *)       echo "Unsupported arch: $ARCH"; return 1 ;;
  esac
  local asset_url
  asset_url=$(curl -fsSL "$api_url" \
    | python3 -c "import json,sys; r=json.load(sys.stdin); print(next(a['browser_download_url'] for a in r['assets'] if 'Linux_${arch}' in a['name']))")
  local tmp
  tmp=$(mktemp -d)
  curl -fsSL "$asset_url" | tar -xz -C "$tmp"
  mkdir -p "$SETUP_HOME/.local/bin"
  mv "$tmp/github-mcp-server" "$dest"
  chmod +x "$dest"
  rm -rf "$tmp"
}

install_shared_mcp_servers() {
  run uv tool install arxiv-mcp-server
  if [ "$OS" = "Darwin" ]; then
    install_macos_formula github-mcp-server
  elif [ "$OS" = "Linux" ]; then
    if ! command -v github-mcp-server &>/dev/null; then
      install_github_mcp_server_linux
    fi
  fi
}

# Write a single MCP entry into a given claude.json path (idempotent).
# Usage: _write_mcp_entry <json_path> <name> <command> <args_json>
_write_mcp_entry() {
  python3 - "$1" "$2" "$3" "$4" <<'PYEOF'
import json, sys
path, name, cmd, args_json = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
args = json.loads(args_json)
try:
    with open(path) as f:
        data = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    data = {}
servers = data.setdefault("mcpServers", {})
entry = {"command": cmd, "args": args}
if servers.get(name) != entry:
    servers[name] = entry
    with open(path, "w") as f:
        json.dump(data, f, indent=2)
    print(f"Registered MCP server '{name}' in {path}")
PYEOF
}

# Register an MCP server entry in ~/.claude.json and all CCS instance
# settings.json files (idempotent).
# Usage: register_claude_mcp <name> <command> [args...]
register_claude_mcp() {
  local name="$1" cmd="$2"
  shift 2
  local args_json
  args_json=$(python3 -c "import json,sys; print(json.dumps(sys.argv[1:]))" "$@")

  _write_mcp_entry "$SETUP_HOME/.claude.json" "$name" "$cmd" "$args_json"

  # Also register in CCS instance settings.json files if CCS is installed.
  local ccs_instances_dir="$SETUP_HOME/.ccs/instances"
  if [ -d "$ccs_instances_dir" ]; then
    local instance_settings
    for instance_settings in "$ccs_instances_dir"/*/settings.json; do
      [ -f "$instance_settings" ] || continue
      _write_mcp_entry "$instance_settings" "$name" "$cmd" "$args_json"
    done
  fi
}
