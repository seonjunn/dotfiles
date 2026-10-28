#!/usr/bin/env python3
"""Install one pinned uv tool beside existing environments, then atomically expose its command."""
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys


def main(uv, name, version, requirements):
    home = Path.home()
    lock = Path(requirements)
    digest = hashlib.sha256(name.encode() + b"\0" + version.encode() + b"\0" + lock.read_bytes()).hexdigest()[:20]
    root = home / ".local/share/uv/locked-tools" / f"{name}-{version}-{digest}"
    tool = root / "tools" / name
    exe = root / "bin" / name
    if not exe.exists():
        root.mkdir(parents=True, exist_ok=True)
        env = dict(os.environ, UV_TOOL_DIR=str(root / "tools"), UV_TOOL_BIN_DIR=str(root / "bin"))
        p = subprocess.run([uv, "tool", "install", "--with-requirements", str(lock),
                            f"{name}=={version}", "--python", "3.12", "--managed-python"],
                           env=env, capture_output=True, text=True)
        if p.returncode or not exe.exists():
            raise RuntimeError(f"{name}: pinned uv install failed: {p.stderr[-1200:]}")
    # Detect a manually changed environment. Lock entries can have multiple platform-marked versions.
    allowed = {(n.lower().replace("_", "-"), v) for n, v in
               re.findall(r"(?m)^([A-Za-z0-9_.-]+)==([A-Za-z0-9_.!+-]+)", lock.read_text())}
    p = subprocess.run([str(tool / "bin/python"), "-c",
                        "import importlib.metadata as m,json; print(json.dumps({d.metadata['Name']:d.version for d in m.distributions()}))"],
                       capture_output=True, text=True)
    if p.returncode:
        raise RuntimeError(f"{name}: cannot inspect the installed environment: {p.stderr[-500:]}")
    installed = {(n.lower().replace("_", "-"), v) for n, v in json.loads(p.stdout).items()}
    unexpected = sorted(installed - allowed)
    if (name.replace("_", "-"), version) not in installed or unexpected:
        raise RuntimeError(f"{name}: installed packages differ from lock: {unexpected}")
    link = home / ".local/bin" / name
    link.parent.mkdir(parents=True, exist_ok=True)
    if link.is_symlink():
        old = link.resolve()
        uv_root = home / ".local/share/uv"
        if not old.is_relative_to(uv_root):
            raise RuntimeError(f"{name}: {link} belongs to another installer: {old}")
    elif link.exists():
        raise RuntimeError(f"{name}: {link} is a user file; keep it and report the conflict")
    if not link.is_symlink() or link.resolve() != exe.resolve():
        tmp = link.with_name(link.name + ".hm-new")
        tmp.symlink_to(exe)
        tmp.replace(link)
        print(f"uv: activated {name} {version}")
    state = home / ".local/state/dotfiles/uv-locked"
    state.mkdir(parents=True, exist_ok=True)
    (state / f"{name}.json").write_text(json.dumps({"version": version, "lock": digest, "environment": str(root)}) + "\n")


if __name__ == "__main__":
    main(*sys.argv[1:])
