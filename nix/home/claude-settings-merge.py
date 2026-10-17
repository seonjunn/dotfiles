#!/usr/bin/env python3
"""Merge the dotfiles Claude settings into ~/.claude/settings.json, keeping what Claude wrote.

Usage: claude-settings-merge.py MANAGED_JSON [TARGET_JSON] [STATE_JSON]

settings.json is written by Claude Code itself (/model, "always allow", ...), so it cannot be a
read-only Home Manager link. Instead each switch merges the managed file into it:

- keys the managed file has: objects merge recursively, lists keep Claude's extra items and gain the
  managed ones, anything else takes the managed value;
- keys (and list items) the managed file had at the previous switch but no longer has are removed;
- everything else is left alone.

The managed file applied last time is kept in STATE_JSON to know what was dropped. The first run
backs up the original next to it (settings.json.before-dotfiles).
"""
import json
import os
import shutil
import sys
import tempfile


def merge(cur, new, prev):
    out = dict(cur)
    for k in prev:
        if k not in new:
            out.pop(k, None)
    for k, v in new.items():
        p = prev.get(k)
        c = out.get(k)
        if isinstance(v, dict) and isinstance(c, dict):
            out[k] = merge(c, v, p if isinstance(p, dict) else {})
        elif isinstance(v, list) and isinstance(c, list):
            dropped = [x for x in (p if isinstance(p, list) else []) if x not in v]
            kept = [x for x in c if x not in dropped]
            out[k] = kept + [x for x in v if x not in kept]
        else:
            out[k] = v
    return out


def load(path):
    try:
        with open(path) as f:
            return json.load(f)
    except FileNotFoundError:
        return {}


def write(path, data):
    d = os.path.dirname(os.path.abspath(path))
    os.makedirs(d, exist_ok=True)
    fd, tmp = tempfile.mkstemp(dir=d, prefix=".settings.")
    os.chmod(tmp, os.stat(path).st_mode & 0o777 if os.path.exists(path) else 0o644)  # mkstemp makes 0600
    with os.fdopen(fd, "w") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        f.write("\n")
    os.replace(tmp, path)


def main():
    home = os.path.expanduser("~")
    managed = sys.argv[1]
    target = sys.argv[2] if len(sys.argv) > 2 else f"{home}/.claude/settings.json"
    state = sys.argv[3] if len(sys.argv) > 3 else f"{home}/.local/state/dotfiles/claude-settings.json"

    new = load(managed)
    prev = load(state)
    if os.path.islink(target):  # an old setup left a link; replace it with a real file
        cur = load(target)
        os.unlink(target)
    else:
        cur = load(target)
        backup = target + ".before-dotfiles"
        if os.path.exists(target) and not os.path.exists(state) and not os.path.exists(backup):
            shutil.copy2(target, backup)

    out = merge(cur, new, prev)
    if out != cur or not os.path.exists(target):
        write(target, out)
        print(f"claude settings: updated {target}")
    write(state, new)


if __name__ == "__main__":
    main()
