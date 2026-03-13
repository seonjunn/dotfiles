# Claude Workspace Rules

## CLAUDE.md and AGENTS.md compatibility
When you create or update a repository instruction file, keep both formats present.

- If `CLAUDE.md` is created (including via `/init`), also symlink `AGENTS.md` to `CLAUDE.md`.

## Diagrams

Always use Mermaid syntax when drawing diagrams. Never use `\n` inside Mermaid code blocks — use `<br/>` for line breaks within node labels or text.
