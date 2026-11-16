#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"

echo "[devcontainer-feature]"
for d in devcontainer/*/; do
	d=${d%/}
	f=$d/devcontainer-feature.json
	# The publish Action (devcontainers/action) validates against this schema, a copy of its
	# src/schemas/devContainerFeature.schema.json; it rejected an `external` mount once (2026-11-16).
	python3 -c '
import json, sys
try:
    import jsonschema
except ImportError:
    json.load(open(sys.argv[2]))
    print("SKIP: no python jsonschema, " + sys.argv[2] + " checked as JSON only")
    sys.exit(0)
errors = list(jsonschema.Draft7Validator(json.load(open(sys.argv[1]))).iter_errors(json.load(open(sys.argv[2]))))
for e in errors:
    for c in e.context or [e]:
        print("FAIL: " + sys.argv[2] + " " + "/".join(map(str, c.absolute_path)) + ": " + c.message[:200])
sys.exit(1 if errors else 0)' tests/devcontainer-feature.schema.json "$f"
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
