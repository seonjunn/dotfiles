#!/usr/bin/env python3
"""Claude Code status line, shared by every machine.

model (effort) | user@host:cwd (branch) | account | ctx 82%/1M | cache 12m05s [| UNATTENDED]

Input is the JSON Claude Code passes on stdin. Never prints tokens or secrets:
the account is read from the oauthAccount.emailAddress field only.
"""
import json
import os
import socket
import subprocess
import sys
import time
from pathlib import Path

G, B, M, Y, R, GR, N = (
    "\033[01;32m", "\033[01;34m", "\033[35m", "\033[33m", "\033[31m", "\033[32m", "\033[00m"
)
SEP = " | "


def get(obj, *keys):
    for k in keys:
        obj = obj.get(k) if isinstance(obj, dict) else None
    return obj


def human(n):
    if n >= 1_000_000:
        v = n / 1_000_000
        return f"{v:g}M" if v == int(v) else f"{v:.1f}M"
    if n >= 1000:
        return f"{n // 1000}k"
    return str(n)


def feed_orca(raw):
    # Orca's own status-line hook used to be the status line; keep feeding it, discard its output.
    hook = Path.home() / ".orca/agent-hooks/claude-statusline.sh"
    if hook.is_file() and os.access(hook, os.X_OK):
        try:
            subprocess.run(["/bin/sh", str(hook)], input=raw, capture_output=True, timeout=2, text=True)
        except Exception:
            pass


def branch(cwd):
    for args in (["symbolic-ref", "--short", "-q", "HEAD"], ["rev-parse", "--short", "HEAD"]):
        try:
            out = subprocess.run(
                ["git", "--no-optional-locks", "-C", cwd, *args], capture_output=True, text=True, timeout=1
            ).stdout.strip()
        except Exception:
            return ""
        if out:
            return out
    return ""


def account():
    cfg = Path(os.environ.get("CLAUDE_CONFIG_DIR") or Path.home() / ".claude")
    for f in (cfg / ".claude.json", Path.home() / ".claude.json"):
        try:
            email = get(json.loads(f.read_text()), "oauthAccount", "emailAddress")
        except Exception:
            continue
        if email:
            return email
    return cfg.name


def mode(session_id):
    # Optional: a file holding "unattended" marks the session as running without a person.
    if not session_id:
        return ""
    f = Path.home() / ".local/state/agent" / f"mode-{session_id}"
    try:
        return f.read_text().strip()
    except Exception:
        return ""


def main():
    raw = sys.stdin.read()
    feed_orca(raw)
    try:
        d = json.loads(raw)
    except Exception:
        d = {}

    parts = []
    model = get(d, "model", "display_name")
    effort = get(d, "effort", "level")
    if model:
        parts.append(f"{model} ({effort})" if effort else str(model))

    cwd = get(d, "workspace", "current_dir") or d.get("cwd") or os.getcwd()
    home = str(Path.home())
    shown = "~" + cwd[len(home):] if cwd == home or cwd.startswith(home + "/") else cwd
    loc = f"{G}{os.environ.get('USER', '')}@{socket.gethostname().split('.')[0]}{N}:{B}{shown}{N}"
    br = branch(cwd)
    if br:
        loc += f" {M}({br}){N}"
    parts.append(loc)

    parts.append(account())

    used = get(d, "context_window", "used_percentage")
    size = get(d, "context_window", "context_window_size")
    if isinstance(used, (int, float)):
        c = R if used >= 90 else Y if used >= 80 else GR
        ctx = f"{c}ctx {round(used)}%{N}"
        if isinstance(size, (int, float)) and size:
            ctx += f"/{human(int(size))}"
        parts.append(ctx)

    pc = d.get("prompt_cache")
    if isinstance(pc, dict):
        exp = pc.get("expires_at")
        try:
            exp = float(exp)
        except (TypeError, ValueError):
            exp = None
        left = exp - time.time() if exp else None
        if pc.get("warm") and left and left > 0:
            secs = int(left)
            mins = secs // 60
            t = f"{mins // 60}h{mins % 60:02d}m" if mins >= 60 else f"{mins}m{secs % 60:02d}s"
            parts.append(f"{Y if left < 300 else GR}cache {t}{N}")
        else:
            parts.append(f"{R}cache {'expired' if pc.get('warm') else 'cold'}{N}")

    m = mode(d.get("session_id"))
    if m == "unattended":
        parts.append(f"{Y}UNATTENDED{N}")

    sys.stdout.write(SEP.join(parts))


main()
