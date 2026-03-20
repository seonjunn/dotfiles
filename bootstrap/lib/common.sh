#!/usr/bin/env bash

# Recover SSH_AUTH_SOCK when sudo has stripped it from the environment.
# On Linux, walks /proc looking for a live agent socket in SUDO_USER's processes.
# On macOS, sudo typically preserves it via env_keep so this is a no-op.
recover_ssh_auth_sock() {
  [ -n "${SSH_AUTH_SOCK:-}" ] && return 0
  [ -z "${SUDO_USER:-}" ] && return 0
  [ "$(id -u)" -eq 0 ] || return 0
  [ "$(uname -s)" = "Linux" ] || return 0
  local pid sock
  for pid in $(pgrep -u "$SUDO_USER" 2>/dev/null); do
    sock=$(tr '\0' '\n' < "/proc/$pid/environ" 2>/dev/null \
           | grep '^SSH_AUTH_SOCK=' | head -1 | cut -d= -f2-) || true
    if [ -n "$sock" ] && [ -S "$sock" ]; then
      export SSH_AUTH_SOCK="$sock"
      return 0
    fi
  done
}

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

  # Point HOME at the real user so every tool (git, nvm, cargo, …) uses
  # the right home directory.  We still run as uid 0 for privilege.
  export HOME="$TARGET_HOME"

  SETUP_HOME="$TARGET_HOME"
  SETUP_DOTFILES_DIR="${DOTFILES_DIR:-$SETUP_HOME/.dotfiles}"
  export TARGET_USER TARGET_HOME SETUP_HOME SETUP_DOTFILES_DIR

  [ -d "$SETUP_HOME/.local/bin" ] && export PATH="$SETUP_HOME/.local/bin:$PATH"
  ZB_PREFIX="${ZEROBREW_PREFIX:-/opt/zerobrew/prefix}"
  [ -d "$SETUP_HOME/.zerobrew/bin" ] && export PATH="$SETUP_HOME/.zerobrew/bin:$PATH"
  [ -d "$ZB_PREFIX/bin" ] && export PATH="$ZB_PREFIX/bin:$PATH"
  NVM_DIR="${NVM_DIR:-$SETUP_HOME/.nvm}"
  if [ -s "$NVM_DIR/nvm.sh" ]; then
    . "$NVM_DIR/nvm.sh"
    export NVM_DIR
  fi
  [ -f "$SETUP_HOME/.cargo/env" ] && . "$SETUP_HOME/.cargo/env"

  HAS_SUDO=false
  [ -n "${SUDO_USER:-}" ] && HAS_SUDO=true
  export HAS_SUDO

  recover_ssh_auth_sock

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

# Run a command as the target (non-root) user when invoked via sudo.
# Used for commands that create files in the user's home (git, etc.)
# so they are owned by the user, not root.  HOME is already set globally;
# SSH_AUTH_SOCK is forwarded so SSH uses the user's agent.
as_user() {
  if [ -n "${SUDO_USER:-}" ] && [ "$(id -u)" -eq 0 ]; then
    local env_args=("HOME=$HOME")
    [ -n "${SSH_AUTH_SOCK:-}" ] && env_args+=("SSH_AUTH_SOCK=$SSH_AUTH_SOCK")
    sudo -u "$TARGET_USER" env "${env_args[@]}" "$@"
  else
    "$@"
  fi
}

# Like as_user but wrapped in run() for dry-run / verbose support.
run_as_user() {
  if [ -n "${SUDO_USER:-}" ] && [ "$(id -u)" -eq 0 ]; then
    local env_args=("HOME=$HOME")
    [ -n "${SSH_AUTH_SOCK:-}" ] && env_args+=("SSH_AUTH_SOCK=$SSH_AUTH_SOCK")
    run sudo -u "$TARGET_USER" env "${env_args[@]}" "$@"
  else
    run "$@"
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

# Write an mcpServers entry into a Claude-format settings JSON (idempotent).
# Usage: _write_mcp_settings <json_path> <name> <command> <args_json> <env_json>
_write_mcp_settings() {
  python3 - "$1" "$2" "$3" "$4" "$5" <<'PYEOF'
import json, sys
path, name, cmd, args_json, env_json = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5]
args = json.loads(args_json)
env = json.loads(env_json)
try:
    with open(path) as f:
        data = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    data = {}
servers = data.setdefault("mcpServers", {})
entry = {"command": cmd, "args": args}
if env:
    entry["env"] = env
if servers.get(name) != entry:
    servers[name] = entry
    with open(path, "w") as f:
        json.dump(data, f, indent=2)
    print(f"Registered MCP server '{name}' in {path}")
PYEOF
}

# Register an MCP server in all CCS instance configs (idempotent).
# Falls back to claude mcp add --scope user when no CCS instances exist.
# Usage: register_claude_mcp <name> [-e KEY=VAL]... -- <command> [args...]
register_claude_mcp() {
  local name="$1"
  shift

  # Collect -e/--env KEY=VAL pairs before the -- separator.
  local env_args=()
  while [[ "${1:-}" == "-e" || "${1:-}" == "--env" ]]; do
    env_args+=("$2")
    shift 2
  done
  [[ "${1:-}" == "--" ]] && shift

  local cmd="$1"; shift
  local args_json env_json
  args_json=$(python3 -c "import json,sys; print(json.dumps(sys.argv[1:]))" "$@")
  env_json=$(python3 -c "
import json, sys
d = {}
for p in sys.argv[1:]:
    k, v = p.split('=', 1)
    d[k] = v
print(json.dumps(d))
" "${env_args[@]+"${env_args[@]}"}")

  local ccs_instances_dir="$SETUP_HOME/.ccs/instances"
  if [ -d "$ccs_instances_dir" ]; then
    # Write to every existing CCS instance config.
    local instance_claude_json
    for instance_claude_json in "$ccs_instances_dir"/*/.claude.json; do
      [ -f "$instance_claude_json" ] || continue
      _write_mcp_settings "$instance_claude_json" "$name" "$cmd" "$args_json" "$env_json"
    done
  else
    # No CCS — fall back to claude CLI (writes to ~/.claude.json).
    local claude_env_flags=()
    for ev in "${env_args[@]+"${env_args[@]}"}"; do
      claude_env_flags+=(-e "$ev")
    done
    claude mcp remove "$name" --scope user 2>/dev/null || true
    run claude mcp add --scope user "${claude_env_flags[@]+"${claude_env_flags[@]}"}" "$name" -- "$cmd" "$@"
  fi
}
