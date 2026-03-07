#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"

require_bash4 || exit 0

echo "[engine]"
source bootstrap/lib/common.sh
source bootstrap/lib/engine.sh
source bootstrap/ops/groups.sh
while IFS= read -r -d '' f; do
  [ "$f" = "bootstrap/ops/groups.sh" ] && continue
  source "$f"
done < <(find bootstrap/ops -type f -name '*.sh' -print0 | sort -z)

for op in "${SETUP_OPS[@]}"; do
  run_fn="$(op_get_runner "$op")"
  verify_fn="$(op_get_verify "$op")"
  category="$(op_get_category "$op")"
  desc="$(op_get_desc "$op")"
  [ -n "$run_fn" ] && [ -n "$verify_fn" ] && [ -n "$category" ] && [ -n "$desc" ]
  declare -F "$run_fn" >/dev/null
  declare -F "$verify_fn" >/dev/null
  [[ "$category" == "installation" || "$category" == "configuration" ]]
done

SETUP_SELECTED_OPS=("${SETUP_OPS[@]}")
resolve_execution_order
idx() { local i=0; for x in "${SETUP_ORDERED_OPS[@]}"; do [ "$x" = "$1" ] && { echo "$i"; return; }; i=$((i+1)); done; echo -1; }
for op in "${SETUP_ORDERED_OPS[@]}"; do
  oi="$(idx "$op")"
  for dep in $(op_get_deps "$op"); do
    di="$(idx "$dep")"
    [ "$di" -ge 0 ] && [ "$di" -lt "$oi" ]
  done
done

echo "PASS engine"
