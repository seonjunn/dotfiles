#!/usr/bin/env bash

run_ccs() {
  run npm install -g @kaitranntt/ccs
}

verify_ccs() {
  command -v ccs &>/dev/null
}

declare -A OP_CCS=(
  [name]="ccs"
  [category]="installation"
  [deps]="node"
  [run_fn]="run_ccs"
  [verify_fn]="verify_ccs"
  [desc]="ccs"
)
register_operation OP_CCS
