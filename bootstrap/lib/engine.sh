#!/usr/bin/env bash

SETUP_OPS=()
SETUP_GROUPS=()
SETUP_GROUP_MODULES=()
SETUP_SELECTED_OPS=()
SETUP_ORDERED_OPS=()

register_group() {
  local group="$1"
  local modules="$2"
  SETUP_GROUPS+=("$group")
  SETUP_GROUP_MODULES+=("$modules")
}

register_operation() {
  local ref="$1"
  local name category deps run_fn verify_fn desc

  eval "name=\${${ref}[name]}"
  eval "category=\${${ref}[category]}"
  eval "deps=\${${ref}[deps]}"
  eval "run_fn=\${${ref}[run_fn]}"
  eval "verify_fn=\${${ref}[verify_fn]}"
  eval "desc=\${${ref}[desc]}"

  if [ -z "$name" ] || [ -z "$category" ] || [ -z "$run_fn" ] || [ -z "$verify_fn" ]; then
    echo "error: operation metadata is missing required fields in '$ref'" >&2
    return 1
  fi

  SETUP_OPS+=("$name")
  eval "SETUP_OP_CATEGORY_${name}=\"${category}\""
  eval "SETUP_OP_DEPS_${name}=\"${deps}\""
  eval "SETUP_OP_RUN_${name}=\"${run_fn}\""
  eval "SETUP_OP_VERIFY_${name}=\"${verify_fn}\""
  eval "SETUP_OP_DESC_${name}=\"${desc}\""
}

op_exists() {
  local name="$1"
  local op
  for op in "${SETUP_OPS[@]}"; do
    [ "$op" = "$name" ] && return 0
  done
  return 1
}

op_get_category() {
  local name="$1"
  eval "printf '%s' \"\${SETUP_OP_CATEGORY_${name}:-}\""
}

op_get_runner() {
  local name="$1"
  eval "printf '%s' \"\${SETUP_OP_RUN_${name}:-}\""
}

op_get_verify() {
  local name="$1"
  eval "printf '%s' \"\${SETUP_OP_VERIFY_${name}:-}\""
}

op_get_deps() {
  local name="$1"
  eval "printf '%s' \"\${SETUP_OP_DEPS_${name}:-}\""
}

op_get_desc() {
  local name="$1"
  eval "printf '%s' \"\${SETUP_OP_DESC_${name}:-}\""
}

resolve_prefix() {
  local prefix="$1"
  local op
  local matches=()

  for op in "${SETUP_OPS[@]}"; do
    [[ "$op" == "$prefix"* ]] && matches+=("$op")
  done

  case ${#matches[@]} in
    1) printf '%s\n' "${matches[0]}" ;;
    0)
      echo "error: no module matches '$prefix'" >&2
      return 1
      ;;
    *)
      echo "error: ambiguous '$prefix': ${matches[*]}" >&2
      return 1
      ;;
  esac
}

add_unique() {
  local arr_name="$1"
  local value="$2"
  local item
  eval "local current=(\"\${${arr_name}[@]-}\")"
  for item in "${current[@]}"; do
    [ "$item" = "$value" ] && return 0
  done
  eval "${arr_name}+=(\"$value\")"
}

collect_with_deps() {
  local name="$1"
  local deps dep

  if ! op_exists "$name"; then
    echo "error: unknown module '$name'" >&2
    return 1
  fi

  add_unique SETUP_SELECTED_OPS "$name"
  deps="$(op_get_deps "$name")"
  for dep in $deps; do
    collect_with_deps "$dep"
  done
}

reset_marks() {
  local op
  for op in "${SETUP_SELECTED_OPS[@]}"; do
    eval "SETUP_MARK_${op}=0"
  done
}

visit_for_sort() {
  local name="$1"
  local deps dep mark

  eval "mark=\${SETUP_MARK_${name}:-0}"
  if [ "$mark" = "2" ]; then
    return 0
  fi
  if [ "$mark" = "1" ]; then
    echo "error: dependency cycle detected at '$name'" >&2
    return 1
  fi

  eval "SETUP_MARK_${name}=1"
  deps="$(op_get_deps "$name")"
  for dep in $deps; do
    add_unique SETUP_SELECTED_OPS "$dep"
    visit_for_sort "$dep"
  done

  eval "SETUP_MARK_${name}=2"
  add_unique SETUP_ORDERED_OPS "$name"
}

resolve_execution_order() {
  local op
  SETUP_ORDERED_OPS=()
  reset_marks
  for op in "${SETUP_SELECTED_OPS[@]}"; do
    visit_for_sort "$op"
  done
}

execute_operation() {
  local op="$1"
  local runner verify desc category

  runner="$(op_get_runner "$op")"
  verify="$(op_get_verify "$op")"
  desc="$(op_get_desc "$op")"
  category="$(op_get_category "$op")"

  [ -z "$desc" ] && desc="$op"
  [ -z "$runner" ] && { echo "error: operation '$op' has no runner" >&2; return 1; }
  [ -z "$verify" ] && { echo "error: operation '$op' has no verify function" >&2; return 1; }

  if "$verify"; then
    skip "$desc"
    return 0
  fi

  section "$desc"
  "$runner"

  if [ "${DRY_RUN:-false}" = true ]; then
    ok
    return 0
  fi

  if ! "$verify"; then
    echo "error: verification failed after running '$op'" >&2
    return 1
  fi

  ok
}
