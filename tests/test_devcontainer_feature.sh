#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"

echo "[devcontainer-feature]"
for d in devcontainer/*/; do
	d=${d%/}
	f=$d/devcontainer-feature.json
	python3 -c 'import json, sys; json.load(open(sys.argv[1]))' "$f"
	[ -x "$d/install.sh" ] || { echo "FAIL: $d/install.sh must be executable"; exit 1; }
	# The publish workflow skips a version that already exists: a staged change to a Feature needs a new version,
	# or it never reaches the containers.
	if [ -n "$(git diff --cached --name-only -- "$d")" ] &&
		! git diff --cached -- "$f" | grep -q '^+[[:space:]]*"version"'; then
		echo "FAIL: $d changed but $f keeps its version"
		exit 1
	fi
done
echo "PASS devcontainer-feature"
