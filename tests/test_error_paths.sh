#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"

require_bash4 || exit 0

echo "[error-paths]"
set +e
./setup.sh --dry-run c >/tmp/test-ambig.out 2>&1
rc1=$?
./setup.sh --dry-run doesnotexist >/tmp/test-unknown.out 2>&1
rc2=$?
set -e
[ $rc1 -ne 0 ]
[ $rc2 -ne 0 ]
grep -F "ambiguous 'c'" /tmp/test-ambig.out >/dev/null
grep -F "no module matches 'doesnotexist'" /tmp/test-unknown.out >/dev/null
rm -f /tmp/test-ambig.out /tmp/test-unknown.out

echo "PASS error-paths"
