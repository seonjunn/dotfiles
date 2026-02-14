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
  ripgrep

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

# Rust + cargo tools
curl -sSf https://sh.rustup.rs | sh -s -- -y
. "$HOME/.cargo/env"
cargo install zoxide --locked
cargo install eza
