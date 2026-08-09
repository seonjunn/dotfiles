# Dotfiles

Personal dotfiles for seonjunkim. Managed as a bare-style repo at `~/.dotfiles`, symlinked into place by `setup.sh`.

## Package manager preference

Prefer **zerobrew** over Homebrew for installing packages. Only fall back to `brew` if zerobrew does not support the package or otherwise cannot be used.

## Platform support

This repo targets both **macOS** and **Ubuntu**. Keep all configs and scripts platform-agnostic:
- No hardcoded absolute paths (use `$HOME`, rely on `$PATH`)
- No macOS-only or Linux-only tools without guarding with `uname` checks
- `setup.sh` handles platform differences (e.g. `brew` vs `apt`) internally

## Structure

| Path | Description |
|---|---|
| `config/fish/` | Fish shell config (symlinked to `~/.config/fish`) |
| `config/vim/` | Vim config (symlinked to `~/.vimrc`) |
| `config/bash/` | Bash config |
| `config/claude/` | Claude Code settings, commands, agents |
| `config/agents/` | Shared agent prompt (`AGENTS.md`) and skills |
| `config/ipython/` | IPython profile |
| `bin/` | Helper scripts added to shell `PATH` |
| `bootstrap/` | Modular setup engine (`bootstrap/setup.sh`, `bootstrap/lib`, `bootstrap/ops`) |
| `setup.sh` | Single bootstrap entrypoint; clones repo if needed and delegates to `bootstrap/setup.sh` |

## Skills

`config/agents/skills/` is the single source of truth for skills across all three consumers. A skill is a directory with a `SKILL.md` at its root carrying `name` and `description` frontmatter.

| Consumer | How it gets the skill |
|---|---|
| Claude Code | `bootstrap/ops/claude.sh` symlinks each top-level entry into `~/.claude/skills/` |
| Codex | `bootstrap/ops/codex.sh` symlinks the whole tree to `~/.agents/skills` |
| Claude app (web/mobile/desktop) | manual upload of a `.skill` archive built by `bin/skill-pack` |

The first two are live symlinks — edit a file and it takes effect. **The app is not.** An uploaded `.skill` is a snapshot; the app's copy stops tracking the source the moment it lands. Edits here do not reach it.

To update the app after changing a skill:

```sh
skill-pack session-export        # writes ~/Downloads/session-export.skill
```

Then in the app: Settings → Capabilities → Skills → delete the old entry → upload the new archive. `skill-pack` with no arguments packs every skill; `-l` lists them, `-o DIR` changes the output directory.

Write skills to work in both environments rather than forking per consumer — branch inside `SKILL.md` on what differs (filesystem paths, available tools) so one file serves all three.

Current skills: `session-export/`.

## Bootstrap order

1. Run `setup.sh` via `sudo bash` (once, on a fresh machine, to grant passwordless sudo)
2. Run `setup.sh` as the target user

## Symlinks created by setup.sh

- `~/.tmux.conf` → `~/.dotfiles/config/tmux/.tmux.conf`
- `~/.vimrc` → `~/.dotfiles/config/vim/.vimrc`
- `~/.config/fish` → `~/.dotfiles/config/fish`
- `~/.ipython/profile_default` → `~/.dotfiles/config/ipython/profile_default`
- `~/.claude/CLAUDE.md` → `~/.dotfiles/config/claude/CLAUDE.md`
- `~/.claude/settings.json` — copied from `~/.dotfiles/config/claude/settings.json` (not symlinked, to avoid circular-symlink detection)
- `~/.claude/commands` → `~/.dotfiles/config/claude/commands`
- `~/.claude/skills` → `~/.dotfiles/config/agents/skills`
- `~/.claude/agents` → `~/.dotfiles/config/claude/agents`
- `~/.codex/AGENTS.md` → `~/.dotfiles/config/agents/AGENTS.md`
- `~/.agents/skills` → `~/.dotfiles/config/agents/skills`

## MCP servers

Claude Code MCP servers are registered in `~/.claude.json` (machine-local, not tracked). `setup.sh` calls `register_claude_mcp` to add them idempotently. Binaries are installed by `install_shared_mcp_servers`. The GitHub server authenticates via `gh auth token` (stored in the OS keychain after `gh auth login`).

Codex MCP servers are configured in `~/.codex/config.toml`. To avoid clobbering host-specific Codex settings (for example `projects.*.trust_level`), `setup.sh` manages Codex MCP entries via `codex mcp add` instead of symlinking a repo-managed `config.toml`.

`setup.sh` installs required MCP server binaries via `uv tool install` (arxiv) and `install_macos_formula` (github-mcp-server).

| Server | Command | Installed by |
|---|---|---|
| `arxiv` | `arxiv-mcp-server` | `uv tool install arxiv-mcp-server` |
| `github` | `github-mcp-server stdio` | `brew install github-mcp-server` + `gh auth login` |
