#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

# System packages
apt-get update
apt-get install -y --no-install-recommends \
  ca-certificates \
  curl \
  gnupg \
  software-properties-common

add-apt-repository -y ppa:git-core/ppa
apt-get update

apt-get install -y --no-install-recommends \
  git \
  fish \
  vim \
  fzf \
  ripgrep

rm -rf /var/lib/apt/lists/*

# Git global config
git config --global user.email "cyanide17@snu.ac.kr"
git config --global user.name "Seonjun Kim"
git config --global push.autoSetupRemote true

# Dotfiles
mkdir -p "$HOME/.config/fish"
rm -rf "$HOME/.dotfiles"
git clone https://github.com/seonjunn/dotfiles "$HOME/.dotfiles"
cp "$HOME/.dotfiles/vim/.vimrc" "$HOME/.vimrc"
cp -r "$HOME/.dotfiles/fish/." "$HOME/.config/fish/"

# Rust + cargo tools
curl -sSf https://sh.rustup.rs | sh -s -- -y
. "$HOME/.cargo/env"
cargo install zoxide --locked
cargo install eza


# Claude code
curl -fsSL https://claude.ai/install.sh | bash
