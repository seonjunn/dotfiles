#!/usr/bin/env bash

run_sudoer() {
  local sudoers_file="/etc/sudoers.d/${SUDO_USER}"
  run "echo '${SUDO_USER} ALL=(ALL) NOPASSWD: ALL' > ${sudoers_file}"
  run chmod 0440 "$sudoers_file"
  run visudo -cf "$sudoers_file"
}

verify_sudoer() {
  if [ "$HAS_SUDO" = true ] && [ "$(id -u)" -eq 0 ]; then
    [ -f "/etc/sudoers.d/${SUDO_USER}" ]
  else
    return 0
  fi
}

declare -A OP_SUDOER=(
  [name]="sudoer"
  [category]="configuration"
  [deps]=""
  [run_fn]="run_sudoer"
  [verify_fn]="verify_sudoer"
  [desc]="Sudoer"
)
register_operation OP_SUDOER
