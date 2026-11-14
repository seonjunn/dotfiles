#!/usr/bin/env python3
"""SessionStart hook: tell the agent when this project's auto-memory holds more than a pointer.

Auto-memory is kept on as an inbox; the source of truth is a file the user can see in the repo.
Anything else in the memory directory (a topic file, or a MEMORY.md longer than one line) is waiting
to be moved there. This adds one line to the session's context, every session, until it is moved.
Prints nothing when the inbox is empty or anything goes wrong.
"""
import json
import re
import subprocess
import sys
from pathlib import Path


def memory_dirs(data):
    """The project's memory dir: next to the transcript (<config>/projects/<cwd>/memory), and the one
    keyed by the git root when the session started in a subdirectory."""
    dirs = []
    t = data.get("transcript_path")
    if t:
        dirs.append(Path(t).parent / "memory")
        cwd = data.get("cwd") or ""
        try:
            root = subprocess.run(["git", "-C", cwd, "rev-parse", "--show-toplevel"], capture_output=True,
                                  text=True, timeout=5).stdout.strip()
        except (OSError, subprocess.SubprocessError):
            root = ""
        if root:
            dirs.append(Path(t).parent.parent / re.sub(r"[^A-Za-z0-9]", "-", root) / "memory")
    return dict.fromkeys(d.resolve() for d in dirs if d.is_dir())


def waiting(d):
    out = []
    for f in sorted(d.rglob("*")):
        if not f.is_file():
            continue
        if f.name == "MEMORY.md" and f.parent == d \
                and sum(1 for l in f.read_text(errors="replace").splitlines() if l.strip()) <= 1:
            continue
        out.append(f.relative_to(d).as_posix())
    return out


def main():
    data = json.load(sys.stdin)
    lines = []
    for d in memory_dirs(data):
        files = waiting(d)
        if files:
            shown = ", ".join(files[:8]) + (f" 외 {len(files) - 8}개" if len(files) > 8 else "")
            lines.append(f"`{d}`: {shown}")
    if not lines:
        return
    text = ("자동 메모리 수신함: 이 프로젝트의 메모리 폴더에 아직 레포 파일로 옮기지 않은 메모리가 있다. "
            + "; ".join(lines) + ". 원본은 사용자가 볼 수 있는 레포 파일이다(전역 규칙 Memory 절, infra agents/README.md). "
            "지금 일을 끊지 말고, 자연스러운 때에 사용자에게 한 번 알리고 어디로 옮길지 제안한다. "
            "옮긴 뒤 메모리 폴더에는 한 줄 포인터 MEMORY.md만 남긴다.")
    print(json.dumps({"hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": text}},
                     ensure_ascii=False))


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass
