#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

SKIP_SUDO=false
DRY_RUN=false
for arg in "$@"; do
  case $arg in
    --no-sudo) SKIP_SUDO=true ;;
    --dry-run) DRY_RUN=true ;;
    --help|-h)
      echo "Usage: setup.sh [OPTIONS]"
      echo ""
      echo "Bootstrap a new machine with dotfiles and tools."
      echo ""
      echo "Options:"
      echo "  --no-sudo   Skip system package installation (apt-get)"
      echo "  --dry-run   Print commands without executing them"
      echo "  --help, -h  Show this help message"
      exit 0
      ;;
  esac
done

run() {
  if [ "$DRY_RUN" = true ]; then
    echo "  $*"
  else
    "$@"
  fi
}

SUDO=""
if [ "$SKIP_SUDO" = false ]; then
  [ "$(id -u)" -ne 0 ] && SUDO="sudo"
fi

# System packages
if [ "$SKIP_SUDO" = true ]; then
  echo "Skipping system package installation (--no-sudo)"
else
  run $SUDO apt-get update
  run $SUDO apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gnupg \
    software-properties-common

  run $SUDO add-apt-repository -y ppa:git-core/ppa
  run $SUDO apt-get update

  run $SUDO apt-get install -y --no-install-recommends \
    git \
    fish \
    vim \
    fzf \
    ripgrep

  run $SUDO rm -rf /var/lib/apt/lists/*
fi

# Node.js (via nvm)
if [ "$DRY_RUN" = true ]; then
  echo "  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | PROFILE=/dev/null bash"
  echo "  nvm install --lts"
  echo "  nvm alias default lts/*"
else
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | PROFILE=/dev/null bash
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  nvm install --lts
  nvm alias default lts/*
fi

# Git global config
run git config --global user.email "cyanide17@snu.ac.kr"
run git config --global user.name "Seonjun Kim"
run git config --global push.autoSetupRemote true

# Dotfiles
run rm -rf "$HOME/.dotfiles"
run git clone --recurse-submodules https://github.com/seonjunn/dotfiles "$HOME/.dotfiles"
run ln -sf "$HOME/.dotfiles/vim/.vimrc" "$HOME/.vimrc"
run rm -rf "$HOME/.config/fish"
run ln -sf "$HOME/.dotfiles/fish" "$HOME/.config/fish"

# IPython
run mkdir -p "$HOME/.ipython"
run rm -rf "$HOME/.ipython/profile_default"
run ln -sf "$HOME/.dotfiles/ipython/profile_default" "$HOME/.ipython/profile_default"

# Claude
if [ "$DRY_RUN" = true ]; then
  echo "  curl -fsSL https://claude.ai/install.sh | bash"
else
  curl -fsSL https://claude.ai/install.sh | bash
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

# Codex
run npm i -g @openai/codex
run mkdir -p "$HOME/.codex" "$HOME/.agents"
run ln -sf "$HOME/.dotfiles/agents/AGENTS.md" "$HOME/.codex/AGENTS.md"
run rm -rf "$HOME/.agents/skills"
run ln -sf "$HOME/.dotfiles/agents/skills" "$HOME/.agents/skills"

# Rust + cargo tools
if [ "$DRY_RUN" = true ]; then
  echo "  curl -sSf https://sh.rustup.rs | sh -s -- -y"
  echo "  cargo install zoxide --locked"
  echo "  cargo install eza"
else
  curl -sSf https://sh.rustup.rs | sh -s -- -y
  . "$HOME/.cargo/env"
  cargo install zoxide --locked
  cargo install eza
fi
