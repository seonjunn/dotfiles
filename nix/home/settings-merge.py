#!/usr/bin/env python3
"""Merge a managed JSON file into a settings file an app also writes, keeping what the app wrote.

Usage: settings-merge.py LABEL MANAGED_JSON TARGET_JSON STATE_JSON [INDENT]

Claude Code's ~/.claude/settings.json (/model, "always allow", ...) and VS Code's settings.json (the
Settings UI) are written by the apps themselves, so they cannot be read-only Home Manager links.
Instead each switch merges the managed file into them:

- keys the managed file has: objects merge recursively, lists keep the app's extra items and gain the
  managed ones, anything else takes the managed value;
- keys (and list items) the managed file had at the previous switch but no longer has are removed;
- everything else is left alone.

The managed file applied last time is kept in STATE_JSON to know what was dropped. The first run
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


def merge_list(cur, new, prev):
    dropped = [x for x in (prev if isinstance(prev, list) else []) if x not in new]
    kept = [x for x in cur if x not in dropped]
    return kept + [x for x in new if x not in kept]


def merge(cur, new, prev):
    if isinstance(new, list):
        return merge_list(cur if isinstance(cur, list) else [], new, prev)
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
            out[k] = merge_list(c, v, p)
        else:
            out[k] = v
    return out


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

    out = merge(cur, new, prev)
    if out != cur or not os.path.exists(target):
        write(target, out, indent)
        print(f"{label}: updated {target}")
    write(state, new, 2)


if __name__ == "__main__":
    main()
