#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"

echo "[syntax]"
for f in $(find . -type f \( -name '*.sh' -o -path './bin/*' \) | sort); do
  case "$(head -1 "$f")" in
    *python3*) python3 -c 'import ast, sys; ast.parse(open(sys.argv[1]).read())' "$f" ;;
    *) bash -n "$f" ;;
  esac
done
if command -v fish >/dev/null 2>&1; then
  for f in config/fish/functions/*.fish; do
    fish --no-execute "$f"
  done
fi
echo "PASS syntax"
