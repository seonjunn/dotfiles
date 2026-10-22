#!/usr/bin/env python3
"""Merge a managed JSON file into a settings file an app also writes, keeping what the app wrote.

Usage: settings-merge.py LABEL MANAGED_JSON TARGET_JSON STATE_JSON [INDENT]

Claude Code's ~/.claude/settings.json (/model, "always allow", ...) and VS Code's settings.json (the
Settings UI) are written by the apps themselves, so they cannot be read-only Home Manager links.
Instead each switch merges the managed file into them:

- three-way (decision D38): the managed file now, the one applied last time (STATE_JSON), and the target.
  A key (or list item) still as applied last time takes the managed value, or goes when the managed file
  dropped it; one changed in the app since then is kept and listed in <STATE>.drift.json and on stderr,
  to be declared or reverted (SETTINGS_MERGE_FORCE=1 takes the managed values);
- objects merge key by key; lists keep the app's extra items;
- everything the managed file never had is left alone. The first run
backs up the original next to it (<target>.before-dotfiles).

A list at the top (VS Code's keybindings.json) merges like a list key.

The target may be JSONC as VS Code writes it (trailing commas, and the header comment VS Code puts in a
new keybindings.json, which is dropped). A target with any other comment is left untouched with a
warning: writing it back as JSON would drop it.
"""
import json
import os
import shutil
import sys
import tempfile


MISSING = object()


def merge_list(cur, new, prev, path, drift):
    prev = prev if isinstance(prev, list) else []
    out = [x for x in cur if not (x in prev and x not in new)]  # dropped from the declaration
    for x in new:
        if x in out:
            continue
        if x in prev and not FORCE:  # applied before and removed here by hand: keep it removed
            drift.append({"key": path, "declared": x, "here": "(removed)"})
        else:
            out.append(x)
    return out


def merge(cur, new, prev, path="", drift=None):
    """Three-way: declared now (new), applied last time (prev), on the machine (cur).
    A value still equal to what was applied last time takes the declared one; a value changed here
    since then is kept and reported in drift (decision D38: never overwrite a hand edit silently)."""
    if isinstance(new, list):
        return merge_list(cur if isinstance(cur, list) else [], new, prev, path or "[]", drift)
    out = dict(cur)
    prev = prev if isinstance(prev, dict) else {}
    for k in set(prev) | set(new):
        v, p, c = new.get(k, MISSING), prev.get(k, MISSING), out.get(k, MISSING)
        key = f"{path}/{k}" if path else k
        if isinstance(v, dict) and isinstance(c, dict):
            out[k] = merge(c, v, p, key, drift)
        elif isinstance(v, list) and isinstance(c, list):
            out[k] = merge_list(c, v, p, key, drift)
        elif c == v:
            pass
        elif c == p or FORCE:
            if v is MISSING:
                out.pop(k, None)
            else:
                out[k] = v
        else:
            drift.append({"key": key, "declared": None if v is MISSING else v, "here": None if c is MISSING else c})
    return out


FORCE = os.environ.get("SETTINGS_MERGE_FORCE") == "1"  # take the declared values over hand edits


class HasComments(Exception):
    pass


VSCODE_HEADER = "// Place your key bindings in this file to override the defaults"


def strip_jsonc(text):
    """Drop trailing commas outside strings; raise HasComments if there is a comment."""
    out, i, n = [], 0, len(text)
    while i < n:
        ch = text[i]
        if ch == '"':
            j = i + 1
            while j < n and text[j] != '"':
                j += 2 if text[j] == "\\" else 1
            out.append(text[i:j + 1])
            i = j + 1
        elif ch == "/" and i + 1 < n and text[i + 1] in "/*":
            if not text.startswith(VSCODE_HEADER, i):
                raise HasComments()
            j = text.find("\n", i)
            i = n if j < 0 else j  # VS Code's own header line: drop it
        elif ch == ",":
            j = i + 1
            while j < n and text[j] in " \t\r\n":
                j += 1
            if j < n and text[j] in "}]":
                i += 1  # trailing comma
                continue
            out.append(ch)
            i += 1
        else:
            out.append(ch)
            i += 1
    return "".join(out)


def load(path):
    try:
        with open(path) as f:
            text = f.read()
    except FileNotFoundError:
        return {}
    return json.loads(strip_jsonc(text)) if text.strip() else {}


def write(path, data, indent):
    d = os.path.dirname(os.path.abspath(path))
    os.makedirs(d, exist_ok=True)
    fd, tmp = tempfile.mkstemp(dir=d, prefix=".settings.")
    os.chmod(tmp, os.stat(path).st_mode & 0o777 if os.path.exists(path) else 0o644)  # mkstemp makes 0600
    with os.fdopen(fd, "w") as f:
        json.dump(data, f, indent=indent, ensure_ascii=False)
        f.write("\n")
    os.replace(tmp, path)


def main():
    label, managed, target, state = sys.argv[1:5]
    indent = int(sys.argv[5]) if len(sys.argv) > 5 else 2

    new = load(managed)
    prev = load(state)
    try:
        if os.path.islink(target):  # an old setup left a link; replace it with a real file
            cur = load(target)
            os.unlink(target)
        else:
            cur = load(target)
            backup = target + ".before-dotfiles"
            if os.path.exists(target) and not os.path.exists(state) and not os.path.exists(backup):
                shutil.copy2(target, backup)
    except HasComments:
        print(f"{label}: {target} has comments, left as is (merge by hand or remove the comments)", file=sys.stderr)
        return

    drift = []
    out = merge(cur, new, prev, "", drift)
    if out != cur or not os.path.exists(target):
        write(target, out, indent)
        print(f"{label}: updated {target}")
    write(state, new, 2)
    report = state[:-len(".json")] + ".drift.json" if state.endswith(".json") else state + ".drift"
    if drift:
        write(report, {"target": target, "drift": drift}, 2)
        for d in drift:
            print(f"{label}: kept the edit made here: {d['key']} (declared {json.dumps(d['declared'], ensure_ascii=False)[:60]})", file=sys.stderr)
    elif os.path.exists(report):
        os.remove(report)


if __name__ == "__main__":
    main()
