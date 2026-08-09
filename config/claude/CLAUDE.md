# Claude Workspace Rules

## CLAUDE.md and AGENTS.md compatibility
When you create or update a repository instruction file, keep both formats present.

- If `CLAUDE.md` is created (including via `/init`), also symlink `AGENTS.md` to `CLAUDE.md`.

## Diagrams

Use Mermaid **only for diagrams that go into a file** — a markdown document, README, design doc, or published artifact. There, Mermaid is the default syntax.

**Never use Mermaid in a chat reply.** Chat responses render in a terminal, where Mermaid does not render at all and shows up as broken source. For a diagram in a reply, draw it as ASCII/box art, or write it out as an indented tree or a table.

Inside Mermaid code blocks, never use `\n` — use `<br/>` for line breaks within node labels or text.
