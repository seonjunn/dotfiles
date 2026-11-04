#!/usr/bin/env python3
"""Check slides (and the notes document) against the owner's deck rules before publishing.

Usage:
  lint_deck.py DECK_DIR                 # a deck project with deck.json and slides/*.html
  lint_deck.py SLIDE.html [...]         # individual slide files (all treated as main slides)
  lint_deck.py ... --notes NOTES.md     # also check the notes / meeting document
  lint_deck.py ... --appendix-from ID   # first appendix slide id, if deck.json does not say
  lint_deck.py ... --known TERMS.txt    # one term per line that needs no definition
  lint_deck.py ... --extra-banned F.txt # the project's own word list, same format as banned_words.txt

Exit status 1 if any ERROR. WARN lines must each be looked at and either fixed or kept on purpose.
The CHECK lists (terms, numbers) are not pass/fail: go through them by hand, they are the
questions a reader asks of a slide ("what is this?", "what over what?").

Thresholds were calibrated by comparing slide versions the owner accepted with versions the owner
called too wordy on an earlier deck (the project's records hold the numbers). A word count is a
floor, not the judgement: a slide under the limit can still carry too much.
"""
from __future__ import annotations

import argparse
import html
import json
import re
import sys
from html.parser import HTMLParser
from pathlib import Path

HERE = Path(__file__).resolve().parent

MAIN = {"block": 30, "cell": 12, "body_warn": 70, "body_error": 110}
APPENDIX = {"block": 40, "cell": 14, "body_warn": 140, "body_error": 170}

BLOCK_TAGS = {"p", "li", "td", "th", "h1", "h2", "h3", "h4", "figcaption", "caption", "dt", "dd"}
CELL_TAGS = {"td", "th"}
UNSUPPORTED = {"sub": "error", "sup": "warn"}  # <sub> is not in the slide subset; <sup> unverified

COMMON_TERMS = {
    "CPU", "GPU", "NPU", "DSP", "DMA", "DDR", "SRAM", "DRAM", "L1", "L2", "L3", "SM", "ISA", "SIMD",
    "SIMT", "VLIW", "OoO", "FLOP", "FLOPs", "MAC", "MACs", "IR", "DSL", "API", "OS", "PyTorch",
    "TVM", "XLA", "MLIR", "LLVM", "CUDA", "CUTLASS", "Triton", "LLM", "MLP", "RMSNorm", "LayerNorm",
    "RoPE", "SiLU", "QKV", "KV", "AI", "PoC", "TBD", "OK", "ID", "PDF", "HTML",
}


class SlideParser(HTMLParser):
    """Collect visible text per block element, styles, and tags used. <aside> (notes) is skipped."""

    def __init__(self) -> None:
        super().__init__(convert_charrefs=True)
        self.stack: list[tuple[str, dict]] = []
        self.blocks: list[dict] = []
        self.open_blocks: list[dict] = []
        self.loose: list[str] = []
        self.tags: set[str] = set()
        self.styles: list[tuple[str, str]] = []
        self.in_aside = 0
        self.in_table = 0

    def handle_starttag(self, tag, attrs):
        a = dict(attrs)
        self.tags.add(tag)
        if tag == "aside":
            self.in_aside += 1
        if tag == "table":
            self.in_table += 1
        style = a.get("style") or ""
        if style:
            self.styles.append((tag, style))
        self.stack.append((tag, a))
        if tag in BLOCK_TAGS:
            self.open_blocks.append({"tag": tag, "text": [], "style": self._style_chain(), "table": self.in_table > 0})
        if tag == "br":
            self.stack.pop()

    def handle_startendtag(self, tag, attrs):
        self.handle_starttag(tag, attrs)
        if tag != "br" and self.stack and self.stack[-1][0] == tag:
            self.stack.pop()

    def handle_endtag(self, tag):
        if tag in BLOCK_TAGS:
            for i in range(len(self.open_blocks) - 1, -1, -1):
                if self.open_blocks[i]["tag"] == tag:
                    b = self.open_blocks.pop(i)
                    b["text"] = " ".join(" ".join(b["text"]).split())
                    if not self.in_aside and b["text"]:
                        self.blocks.append(b)
                    break
        for i in range(len(self.stack) - 1, -1, -1):
            if self.stack[i][0] == tag:
                del self.stack[i:]
                break
        if tag == "aside":
            self.in_aside = max(0, self.in_aside - 1)
        if tag == "table":
            self.in_table = max(0, self.in_table - 1)

    def handle_data(self, data):
        if self.in_aside:
            return
        if self.open_blocks:
            self.open_blocks[-1]["text"].append(data)
        elif data.strip():
            self.loose.append(data.strip())

    def _style_chain(self) -> str:
        return ";".join(a.get("style", "") for _, a in self.stack)


def font_px(style_chain: str) -> int | None:
    sizes = re.findall(r"font-size\s*:\s*(\d+)px", style_chain)
    return int(sizes[-1]) if sizes else None


def hex_colors(style: str) -> list[str]:
    return [c.upper() for c in re.findall(r"#[0-9A-Fa-f]{6}\b", style)]


def is_neutral(c: str) -> bool:
    r, g, b = int(c[1:3], 16), int(c[3:5], 16), int(c[5:7], 16)
    return max(r, g, b) - min(r, g, b) <= 24  # black, white, greys (incl. slightly blue-grey)


def load_banned(path: Path) -> list[tuple[str, re.Pattern, str]]:
    out = []
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        sev, rest = line.split(None, 1)
        pat = rest.split("  #", 1)[0].split(" #", 1)[0].strip()
        out.append((sev, re.compile(pat, re.IGNORECASE), pat))
    return out


def words(s: str) -> int:
    return len(s.split())


def deck_slides(deck_dir: Path, appendix_from: str | None) -> list[tuple[str, Path, bool]]:
    deck = json.loads((deck_dir / "deck.json").read_text(encoding="utf-8"))
    order = deck.get("order") or [p.stem for p in sorted((deck_dir / "slides").glob("*.html"))]
    start = appendix_from
    if start is None:
        for sec in (deck.get("sections") or {}).values():
            if str(sec.get("description", "")).lower().startswith("appendix"):
                start = sec.get("start")
    out, in_app = [], False
    for sid in order:
        if sid == start:
            in_app = True
        out.append((sid, deck_dir / "slides" / f"{sid}.html", in_app))
    return out


def lint_slide(sid, path, appendix, banned, known, report, term_first, numbers):
    p = SlideParser()
    p.feed(path.read_text(encoding="utf-8"))
    lim = APPENDIX if appendix else MAIN
    where = f"{sid}{' (appendix)' if appendix else ''}"

    body = [t for b in p.blocks if b["tag"] not in {"h1", "h2"} for t in b["text"].split()]
    body += [t for s in p.loose for t in s.split()]
    nbody = sum(1 for t in body if re.search(r"[A-Za-z\uac00-\ud7a3]", t))
    if nbody > lim["body_error"]:
        report("ERROR", where, f"{nbody} body words (limit {lim['body_error']}): move text to notes or appendix")
    elif nbody > lim["body_warn"]:
        report("WARN", where, f"{nbody} body words (above {lim['body_warn']}): is every line needed on screen?")
    for b in p.blocks:
        n = words(b["text"])
        if b["tag"] in CELL_TAGS:
            if n > lim["cell"]:
                report("ERROR", where, f"table cell of {n} words (limit {lim['cell']}): \"{b['text'][:90]}\"")
        elif b["tag"] not in {"h1", "h2"} and n > lim["block"]:
            report("WARN", where, f"text block of {n} words (above {lim['block']}): \"{b['text'][:90]}\"")
        if b["tag"] in {"h2", "h1"} and n > 10:
            report("WARN", where, f"title of {n} words: a title is a plain short description")

    title_px = max([font_px(b["style"]) or 0 for b in p.blocks if b["tag"] in {"h1", "h2"}] or [56])
    for b in p.blocks:
        px = font_px(b["style"]) or 0
        if b["tag"] not in {"h1", "h2"} and px >= max(48, title_px) and re.search(r"\d", b["text"]):
            report("WARN", where, f"number shown at {px}px (title {title_px}px): big-number displays read as hype; use a table with context")
        if re.search(r"\d[^→]{0,12}→[^→]{0,12}\d", b["text"]) and px >= 40:
            report("WARN", where, f"big number-arrow-number: \"{b['text'][:60]}\"")

    accents = sorted({c for _, s in p.styles for c in hex_colors(s) if not is_neutral(c)})
    if len(accents) > 1:
        report("ERROR", where, f"{len(accents)} accent colors {accents}: one accent color only")
    for tag, sev in UNSUPPORTED.items():
        if tag in p.tags:
            report(sev.upper(), where, f"<{tag}> used: not reliably supported by the slide renderer")

    alltext = " ".join([b["text"] for b in p.blocks] + p.loose)
    seen = set()
    for sev, rx, pat in banned:
        for m in rx.finditer(alltext):
            w = m.group(0)
            if w in COMMON_TERMS or w in known or (w, pat) in seen:
                continue
            seen.add((w, pat))
            report(sev.upper(), where, f"banned or suspect word \"{w}\" (rule {pat})")
    if re.search(r"\d\s*~\s*\d", alltext):
        report("ERROR", where, "range written with '~': use '-' (tilde pairs render as strikethrough)")

    for tok in re.findall(r"\b(?:[A-Z][A-Za-z]*[A-Z0-9][A-Za-z0-9]*|[a-z]+_[a-z_]+|[A-Za-z]+\d+[A-Za-z]*)\b", alltext):
        if tok in known or tok in COMMON_TERMS or re.fullmatch(r"\d+[A-Za-z]{0,3}", tok):
            continue
        term_first.setdefault(tok, sid)
    for b in p.blocks:
        if re.search(r"\d", b["text"]) and re.search(r"[×x%]|\d\.\d", b["text"]):
            numbers.append((sid, b["text"][:110]))


def lint_notes(path: Path, banned, report):
    text = path.read_text(encoding="utf-8")
    for lineno, line in enumerate(text.splitlines(), 1):
        for sev, rx, pat in banned:
            if any("가" <= ch <= "힣" for ch in pat):  # Korean rules apply to the notes
                for m in rx.finditer(line):
                    report(sev.upper(), f"{path.name}:{lineno}", f"forced Korean \"{m.group(0)}\" (rule {pat})")
        if re.search(r"\d\s*~\s*\d", line):
            report("ERROR", f"{path.name}:{lineno}", "range written with '~': use '-'")


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("paths", nargs="+", type=Path)
    ap.add_argument("--notes", type=Path)
    ap.add_argument("--appendix-from")
    ap.add_argument("--known", type=Path)
    ap.add_argument("--banned", type=Path, default=HERE / "banned_words.txt")
    ap.add_argument("--extra-banned", type=Path, action="append", default=[])
    args = ap.parse_args()

    banned = load_banned(args.banned)
    for extra in args.extra_banned:
        banned += load_banned(extra)
    known = set()
    if args.known:
        known = {l.strip() for l in args.known.read_text(encoding="utf-8").splitlines() if l.strip()}

    slides: list[tuple[str, Path, bool]] = []
    for p in args.paths:
        if p.is_dir():
            slides += deck_slides(p, args.appendix_from)
        else:
            slides.append((p.stem, p, False))

    counts = {"ERROR": 0, "WARN": 0}
    lines: list[str] = []

    def report(sev, where, msg):
        counts[sev] = counts.get(sev, 0) + 1
        lines.append(f"{sev:5s} {where}: {msg}")

    term_first: dict[str, str] = {}
    numbers: list[tuple[str, str]] = []
    for sid, path, app in slides:
        if not path.exists():
            report("ERROR", sid, f"slide file missing: {path}")
            continue
        lint_slide(sid, path, app, banned, known, report, term_first, numbers)
    if args.notes:
        lint_notes(args.notes, banned, report)

    print("\n".join(lines) if lines else "no ERROR or WARN")
    print("\nCHECK terms (first slide where each appears; defined there, or standard in the field?):")
    for tok, sid in sorted(term_first.items(), key=lambda kv: [s for s, _, _ in slides].index(kv[1]) if kv[1] in [s for s, _, _ in slides] else 0):
        print(f"  {sid:14s} {tok}")
    print("\nCHECK numbers (each: what over what, which model/phone/sessions, and what to read from it):")
    for sid, t in numbers:
        print(f"  {sid:14s} {t}")
    print(f"\n{counts.get('ERROR', 0)} ERROR, {counts.get('WARN', 0)} WARN")
    return 1 if counts.get("ERROR", 0) else 0


if __name__ == "__main__":
    sys.exit(main())
