#!/usr/bin/env bash

run_yq() {
  local yq_arch

  if [ "$OS" = "Darwin" ]; then
    run zb install yq
  elif [ "$HAS_SUDO" = true ]; then
    yq_arch=amd64
    [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ] && yq_arch=arm64
    run curl -fsSL "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${yq_arch}" -o /usr/local/bin/yq
    run chmod +x /usr/local/bin/yq
  fi
}

verify_yq() {
  if [ "$OS" = "Darwin" ] || [ "$HAS_SUDO" = true ]; then
    command -v yq &>/dev/null
  else
    return 0
  fi
}

declare -A OP_YQ=(
  [name]="yq"
  [category]="installation"
  [deps]="packages"
  [run_fn]="run_yq"
  [verify_fn]="verify_yq"
  [desc]="yq"
)
register_operation OP_YQ
