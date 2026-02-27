#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

SKIP_SUDO=false
DRY_RUN=false
VERBOSE=false
for arg in "$@"; do
  case $arg in
    --no-sudo)  SKIP_SUDO=true ;;
    --dry-run)  DRY_RUN=true ;;
    --verbose)  VERBOSE=true ;;
    --help|-h)
      echo "Usage: setup.sh [OPTIONS]"
      echo ""
      echo "Bootstrap a new machine with dotfiles and tools."
      echo ""
      echo "Options:"
      echo "  --no-sudo   Skip system package installation (apt-get)"
      echo "  --dry-run   Print commands without executing them"
      echo "  --verbose   Show command output"
      echo "  --help, -h  Show this help message"
      exit 0
      ;;
  esac
done

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

SECTION=""
trap '[ -n "$SECTION" ] && echo "[fail] $SECTION"' ERR

section() {
  SECTION="$1"
  echo "[....] $1"
}

ok() {
  echo "[ ok ] $SECTION"
  SECTION=""
}

skip() {
  echo "[skip] $1"
  SECTION=""
}

SUDO=""
if [ "$SKIP_SUDO" = false ]; then
  if [ "$(id -u)" -eq 0 ]; then
    : # running as root, no sudo needed
  elif sudo -n true &>/dev/null; then
    SUDO="sudo"
  else
    echo "error: sudo privileges required."
    echo "Run 'add-sudoer' as root first, or use --no-sudo to skip system package installation."
    exit 1
  fi
fi

# System packages
if [ "$SKIP_SUDO" = true ]; then
  skip "System packages (--no-sudo)"
elif command -v git &>/dev/null && command -v fish &>/dev/null && command -v fzf &>/dev/null && command -v rg &>/dev/null; then
  skip "System packages"
else
  section "System packages"
  run $SUDO apt-get update -q
  run $SUDO apt-get install -y -q --no-install-recommends \
    ca-certificates \
    curl \
    gnupg \
    software-properties-common
  run $SUDO add-apt-repository -y ppa:git-core/ppa
  run $SUDO apt-get update -q
  run $SUDO apt-get install -y -q --no-install-recommends \
    git \
    fish \
    vim \
    fzf \
    ripgrep
  run $SUDO rm -rf '/var/lib/apt/lists/*'
  ok
fi

# yq
if [ "$SKIP_SUDO" = true ]; then
  skip "yq (--no-sudo)"
elif command -v yq &>/dev/null; then
  skip "yq"
else
  section "yq"
  run $SUDO curl -fsSL "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64" \
    -o /usr/local/bin/yq
  run $SUDO chmod +x /usr/local/bin/yq
  ok
fi

# Node.js (via nvm)
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

# Git global config
section "Git config"
run git config --global user.email "cyanide17@snu.ac.kr"
run git config --global user.name "Seonjun Kim"
run git config --global push.autoSetupRemote true
ok

# Dotfiles
section "Dotfiles"
if [ ! -d "$HOME/.dotfiles/.git" ]; then
  run git clone --recurse-submodules https://github.com/seonjunn/dotfiles "$HOME/.dotfiles"
  run git -C "$HOME/.dotfiles" remote set-url origin git@github.com:seonjunn/dotfiles.git
fi
run ln -sf "$HOME/.dotfiles/vim/.vimrc" "$HOME/.vimrc"
run rm -rf "$HOME/.config/fish"
run ln -sf "$HOME/.dotfiles/fish" "$HOME/.config/fish"
ok

# IPython
section "IPython"
run mkdir -p "$HOME/.ipython"
run rm -rf "$HOME/.ipython/profile_default"
run ln -sf "$HOME/.dotfiles/ipython/profile_default" "$HOME/.ipython/profile_default"
ok

# Claude
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

# Codex
section "Codex"
if ! command -v codex &>/dev/null; then
  run npm i -g @openai/codex
fi
run mkdir -p "$HOME/.codex" "$HOME/.agents"
run ln -sf "$HOME/.dotfiles/agents/AGENTS.md" "$HOME/.codex/AGENTS.md"
run rm -rf "$HOME/.agents/skills"
run ln -sf "$HOME/.dotfiles/agents/skills" "$HOME/.agents/skills"
ok

# Utilities
if command -v ccs &>/dev/null; then
  skip "Utilities"
else
  section "Utilities"
  run npm install -g @kaitranntt/ccs
  ok
fi

# Rust + cargo tools
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

run rm -f "$HOME/.dotfiles/.setup-needed"

echo ""
echo "Done. All stages completed successfully."
