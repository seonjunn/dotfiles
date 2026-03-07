#!/usr/bin/env bash

install_macos_formula() {
  local formula="$1"

  if run zb install "$formula"; then
    return 0
  fi

  ensure_brew
  run brew install "$formula"
}

run_packages() {
  local macos_packages=(git:git fish:fish vim:vim fzf:fzf rg:ripgrep tmux:tmux gum:gum)
  local apt_bootstrap_packages=(ca-certificates curl gnupg software-properties-common)
  local apt_packages=(git fish vim fzf ripgrep tmux gum)
  local pkg command_name formula

  if [ "$OS" = "Darwin" ]; then
    if ! command -v zb &>/dev/null; then
      run "curl -fsSL https://zerobrew.rs/install | bash"
      if [ "$DRY_RUN" = false ]; then
        export PATH="$SETUP_HOME/.local/bin:$PATH"
      fi
    fi

    run zb init
    for pkg in "${macos_packages[@]}"; do
      command_name="${pkg%%:*}"
      formula="${pkg##*:}"
      if ! command -v "$command_name" &>/dev/null; then
        install_macos_formula "$formula"
      fi
    done
  elif [ "$HAS_SUDO" = false ]; then
    :
  else
    run apt-get update -q
    run apt-get install -y -q --no-install-recommends "${apt_bootstrap_packages[@]}"
    run add-apt-repository -y ppa:git-core/ppa
    run mkdir -p /etc/apt/keyrings
    run "curl -fsSL https://repo.charm.sh/apt/gpg.key | gpg --yes --dearmor -o /etc/apt/keyrings/charm.gpg"
    run "echo 'deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *' > /etc/apt/sources.list.d/charm.list"
    run apt-get update -q
    run apt-get install -y -q --no-install-recommends "${apt_packages[@]}"
    run rm -rf '/var/lib/apt/lists/*'
  fi
}

verify_packages() {
  local required_cmds=(git fish fzf rg tmux gum)
  if [ "$OS" = "Darwin" ] || [ "$HAS_SUDO" = true ]; then
    has_all_commands "${required_cmds[@]}"
  else
    # non-sudo Linux: nothing actionable for package install
    return 0
  fi
}

declare -A OP_PACKAGES=(
  [name]="packages"
  [category]="installation"
  [deps]=""
  [run_fn]="run_packages"
  [verify_fn]="verify_packages"
  [desc]="System packages"
)
register_operation OP_PACKAGES
