#!/usr/bin/env bash

run_git_config() {
  run_as_user git config --global user.email "cyanide17@snu.ac.kr"
  run_as_user git config --global user.name "Seonjun Kim"
  run_as_user git config --global push.autoSetupRemote true
}

verify_git_config() {
  [ "$(as_user git config --global --get user.email 2>/dev/null || true)" = "cyanide17@snu.ac.kr" ] \
    && [ "$(as_user git config --global --get user.name 2>/dev/null || true)" = "Seonjun Kim" ] \
    && [ "$(as_user git config --global --get push.autoSetupRemote 2>/dev/null || true)" = "true" ]
}

declare -A OP_GIT=(
  [name]="git"
  [category]="configuration"
  [deps]="packages"
  [run_fn]="run_git_config"
  [verify_fn]="verify_git_config"
  [desc]="Git config"
)
register_operation OP_GIT
