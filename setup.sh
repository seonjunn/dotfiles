#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

# ── CLI ──────────────────────────────────────────────────────────────────────

DRY_RUN=false
VERBOSE=false
LIST=false
MODULES=()

for arg in "$@"; do
  case $arg in
    --dry-run)  DRY_RUN=true ;;
    --verbose)  VERBOSE=true ;;
    --list)     LIST=true ;;
    --help|-h)
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
      echo "  sudoer packages yq node git dotfiles ipython claude codex ccs rust"
      exit 0
      ;;
    -*) echo "unknown flag: $arg" >&2; exit 1 ;;
    *)  MODULES+=("$arg") ;;
  esac
done

export DRY_RUN VERBOSE

# ── Helpers ──────────────────────────────────────────────────────────────────

HAS_SUDO=false
[ -n "${SUDO_USER:-}" ] && HAS_SUDO=true

SECTION=""
trap '[ -n "$SECTION" ] && echo "[fail] $SECTION"' ERR

run() {
  if [ "$DRY_RUN" = true ]; then
    if [ $# -eq 1 ]; then
      echo "  $1"
    else
      printf ' '; printf ' %q' "$@"; printf '\n'
    fi
  elif [ "$VERBOSE" = true ]; then
    if [ $# -eq 1 ]; then eval "$1"; else "$@"; fi
  else
    if [ $# -eq 1 ]; then eval "$1" &>/dev/null; else "$@" &>/dev/null; fi
  fi
}

section() { SECTION="$1"; echo "[....] $1"; }
ok()      { echo "[ ok ] $SECTION"; SECTION=""; }
skip()    { echo "[skip] $1"; SECTION=""; }

# ── Modules ──────────────────────────────────────────────────────────────────

module_sudoer() {
  if [ "$HAS_SUDO" = true ] && [ "$(id -u)" -eq 0 ]; then
    SUDOERS_FILE="/etc/sudoers.d/${SUDO_USER}"
    if [ -f "$SUDOERS_FILE" ]; then
      skip "Sudoer"
    else
      section "Sudoer"
      run "echo '${SUDO_USER} ALL=(ALL) NOPASSWD: ALL' > ${SUDOERS_FILE}"
      run chmod 0440 "$SUDOERS_FILE"
      run visudo -cf "$SUDOERS_FILE"
      ok
    fi
  fi
}

module_packages() {
  if [ "$HAS_SUDO" = false ]; then
    skip "System packages"
  elif command -v git &>/dev/null && command -v fish &>/dev/null && command -v fzf &>/dev/null && command -v rg &>/dev/null; then
    skip "System packages"
  else
    section "System packages"
    run apt-get update -q
    run apt-get install -y -q --no-install-recommends \
      ca-certificates \
      curl \
      gnupg \
      software-properties-common
    run add-apt-repository -y ppa:git-core/ppa
    run apt-get update -q
    run apt-get install -y -q --no-install-recommends \
      git \
      fish \
      vim \
      fzf \
      ripgrep
    run rm -rf '/var/lib/apt/lists/*'
    ok
  fi
}

module_yq() {
  if [ "$HAS_SUDO" = false ]; then
    skip "yq"
  elif command -v yq &>/dev/null; then
    skip "yq"
  else
    section "yq"
    run curl -fsSL "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64" \
      -o /usr/local/bin/yq
    run chmod +x /usr/local/bin/yq
    ok
  fi
}

module_node() {
  if [ -f "$HOME/.nvm/nvm.sh" ]; then
    skip "Node.js"
  else
    section "Node.js"
    run "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | PROFILE=/dev/null bash"
    if [ "$DRY_RUN" = false ]; then
      export NVM_DIR="$HOME/.nvm"
      [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
    fi
    run nvm install --lts
    run nvm alias default lts/*
    ok
  fi
  # Ensure nvm is available for subsequent npm commands
  if [ "$DRY_RUN" = false ] && [ -f "$HOME/.nvm/nvm.sh" ]; then
    export NVM_DIR="$HOME/.nvm"
    . "$NVM_DIR/nvm.sh"
  fi
}

module_git() {
  section "Git config"
  run git config --global user.email "cyanide17@snu.ac.kr"
  run git config --global user.name "Seonjun Kim"
  run git config --global push.autoSetupRemote true
  ok
}

module_dotfiles() {
  section "Dotfiles"
  if [ ! -d "$HOME/.dotfiles/.git" ]; then
    run git clone --recurse-submodules https://github.com/seonjunn/dotfiles "$HOME/.dotfiles"
    run git -C "$HOME/.dotfiles" remote set-url origin git@github.com:seonjunn/dotfiles.git
  fi
  run ln -sf "$HOME/.dotfiles/vim/.vimrc" "$HOME/.vimrc"
  run rm -rf "$HOME/.config/fish"
  run ln -sf "$HOME/.dotfiles/fish" "$HOME/.config/fish"
  ok
}

module_ipython() {
  section "IPython"
  run mkdir -p "$HOME/.ipython"
  run rm -rf "$HOME/.ipython/profile_default"
  run ln -sf "$HOME/.dotfiles/ipython/profile_default" "$HOME/.ipython/profile_default"
  ok
}

module_claude() {
  section "Claude"
  if ! command -v claude &>/dev/null && ! command -v ccs &>/dev/null; then
    run "curl -fsSL https://claude.ai/install.sh | bash"
  fi
  run mkdir -p "$HOME/.claude"
  run ln -sf "$HOME/.dotfiles/agents/AGENTS.md"     "$HOME/.claude/CLAUDE.md"
  run ln -sf "$HOME/.dotfiles/claude/settings.json" "$HOME/.claude/settings.json"
  run rm -rf "$HOME/.claude/commands"
  run ln -sf "$HOME/.dotfiles/claude/commands" "$HOME/.claude/commands"
  run rm -rf "$HOME/.claude/skills"
  run ln -sf "$HOME/.dotfiles/agents/skills"   "$HOME/.claude/skills"
  run rm -rf "$HOME/.claude/agents"
  run ln -sf "$HOME/.dotfiles/claude/agents"   "$HOME/.claude/agents"
  run bash "$HOME/.dotfiles/agents/skills/l4l/install.sh"
  ok
}

module_codex() {
  section "Codex"
  if ! command -v codex &>/dev/null; then
    run npm i -g @openai/codex
  fi
  run mkdir -p "$HOME/.codex" "$HOME/.agents"
  run ln -sf "$HOME/.dotfiles/agents/AGENTS.md" "$HOME/.codex/AGENTS.md"
  run rm -rf "$HOME/.agents/skills"
  run ln -sf "$HOME/.dotfiles/agents/skills" "$HOME/.agents/skills"
  ok
}

module_ccs() {
  if command -v ccs &>/dev/null; then
    skip "ccs"
  else
    section "ccs"
    run npm install -g @kaitranntt/ccs
    ok
  fi
}

module_rust() {
  if [ -f "$HOME/.cargo/bin/rustup" ] && command -v zoxide &>/dev/null && command -v eza &>/dev/null; then
    skip "Rust"
  else
    section "Rust"
    if [ ! -f "$HOME/.cargo/bin/rustup" ]; then
      run "curl -sSf https://sh.rustup.rs | sh -s -- -y"
      [ "$DRY_RUN" = false ] && . "$HOME/.cargo/env"
    fi
    [ "$DRY_RUN" = false ] && [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
    if ! command -v zoxide &>/dev/null; then
      run cargo install zoxide --locked
    fi
    if ! command -v eza &>/dev/null; then
      run cargo install eza
    fi
    ok
  fi
}

# ── Dispatch ─────────────────────────────────────────────────────────────────

ALL_MODULES=(sudoer packages yq node git dotfiles ipython claude codex ccs rust)

if [ "$LIST" = true ]; then
  printf '%s\n' "${ALL_MODULES[@]}"
  exit 0
fi

resolve() {
  local prefix="$1" m matches=()
  for m in "${ALL_MODULES[@]}"; do [[ "$m" == "$prefix"* ]] && matches+=("$m"); done
  case ${#matches[@]} in
    1) echo "${matches[0]}" ;;
    0) echo "error: no module matches '$prefix'" >&2; exit 1 ;;
    *) echo "error: ambiguous '$prefix': ${matches[*]}" >&2; exit 1 ;;
  esac
}

RUN_MODULES=()
if [ ${#MODULES[@]} -eq 0 ]; then
  RUN_MODULES=("${ALL_MODULES[@]}")
else
  for m in "${MODULES[@]}"; do RUN_MODULES+=("$(resolve "$m")"); done
fi

for mod in "${RUN_MODULES[@]}"; do
  "module_${mod}"
done

run rm -f "$HOME/.dotfiles/.setup-needed"

echo ""
echo "Done."
