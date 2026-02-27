#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

# System packages
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
  ca-certificates \
  curl \
  gnupg \
  software-properties-common

sudo add-apt-repository -y ppa:git-core/ppa
sudo apt-get update

sudo apt-get install -y --no-install-recommends \
  git \
  fish \
  vim \
  fzf \
  ripgrep \
  nodejs \
  npm


sudo rm -rf /var/lib/apt/lists/*

# Git global config
git config --global user.email "cyanide17@snu.ac.kr"
git config --global user.name "Seonjun Kim"
git config --global push.autoSetupRemote true

# Dotfiles
rm -rf "$HOME/.dotfiles"
git clone https://github.com/seonjunn/dotfiles "$HOME/.dotfiles"
ln -sf "$HOME/.dotfiles/vim/.vimrc" "$HOME/.vimrc"
rm -rf "$HOME/.config/fish" && ln -sf "$HOME/.dotfiles/fish" "$HOME/.config/fish"

# IPython
mkdir -p "$HOME/.ipython"
rm -rf "$HOME/.ipython/profile_default" && ln -sf "$HOME/.dotfiles/ipython/profile_default" "$HOME/.ipython/profile_default"

# Shared agent config (Claude Code + Codex)
mkdir -p "$HOME/.agents"
rm -rf "$HOME/.agents/skills" && ln -sf "$HOME/.dotfiles/agents/skills" "$HOME/.agents/skills"

# Claude
curl -fsSL https://claude.ai/install.sh | bash
mkdir -p "$HOME/.claude"
ln -sf "$HOME/.dotfiles/agents/AGENTS.md"    "$HOME/.claude/CLAUDE.md"
ln -sf "$HOME/.dotfiles/claude/settings.json" "$HOME/.claude/settings.json"
rm -rf "$HOME/.claude/commands" && ln -sf "$HOME/.dotfiles/claude/commands" "$HOME/.claude/commands"
rm -rf "$HOME/.claude/skills"   && ln -sf "$HOME/.dotfiles/agents/skills"   "$HOME/.claude/skills"
rm -rf "$HOME/.claude/agents"   && ln -sf "$HOME/.dotfiles/claude/agents"   "$HOME/.claude/agents"

# Codex
npm i -g @openai/codex
mkdir -p "$HOME/.codex"
ln -sf "$HOME/.dotfiles/agents/AGENTS.md" "$HOME/.codex/AGENTS.md"

# Rust + cargo tools
curl -sSf https://sh.rustup.rs | sh -s -- -y
. "$HOME/.cargo/env"
cargo install zoxide --locked
cargo install eza
