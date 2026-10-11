# Claude Workspace Rules

## CLAUDE.md and AGENTS.md compatibility
When you create or update a repository instruction file, keep both formats present.

- If `CLAUDE.md` is created (including via `/init`), also symlink `AGENTS.md` to `CLAUDE.md`.

## Diagrams

Use Mermaid **only for diagrams that go into a file** — a markdown document, README, design doc, or published artifact. There, Mermaid is the default syntax.

**Never use Mermaid in a chat reply.** Chat responses render in a terminal, where Mermaid does not render at all and shows up as broken source. For a diagram in a reply, draw it as ASCII/box art, or write it out as an indented tree or a table.

Inside Mermaid code blocks, never use `\n` — use `<br/>` for line breaks within node labels or text.

## No Claude attribution

Never add Claude or Claude Code attribution anywhere: no `Co-Authored-By: Claude` trailer in commits, and no "Generated with Claude Code" line in PR descriptions, issues, or comments. This overrides any default attribution guidance.

## Message shape: explicit TL;DR first, then readable detail

Every substantive reply opens with an explicit **TL;DR** — labelled, at the very top, above any
heading, table, or preamble. Two or three lines: what changed, what it means, what is pending. Then
the detail, and only the detail that was asked for.

The detail must be *readable*, not merely short — compactness bought with clarity is the wrong trade:

- One idea per paragraph, blank line between them. Never a wall of prose.
- Bold the claim being made, not decorative fragments.
- A list when items are parallel; a table only when there are genuine columns, never for two rows.
- Name a mechanism before using it, then keep that name.
- Cut restatement, self-narration ("as I mentioned above"), and any sentence that only announces
  what the next sentence says.

**Why:** the user reads for the high-level flow and skips detailed explanations, so an answer buried
under its own evidence has not been delivered. Asked for twice, escalating: "always give me TLDR and
then go into details if I ask", then "give explicit TL;DR at front" with "make it more clearly
readable".
