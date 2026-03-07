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

## Bootstrap order

1. Run `setup.sh` via `sudo bash` (once, on a fresh machine, to grant passwordless sudo)
2. Run `setup.sh` as the target user

## Symlinks created by setup.sh

- `~/.tmux.conf` → `~/.dotfiles/config/tmux/.tmux.conf`
- `~/.vimrc` → `~/.dotfiles/config/vim/.vimrc`
- `~/.config/fish` → `~/.dotfiles/config/fish`
- `~/.ipython/profile_default` → `~/.dotfiles/config/ipython/profile_default`
- `~/.claude/CLAUDE.md` → `~/.dotfiles/config/claude/CLAUDE.md`
- `~/.claude/settings.json` → `~/.dotfiles/config/claude/settings.json`
- `~/.claude/commands` → `~/.dotfiles/config/claude/commands`
- `~/.claude/skills` → `~/.dotfiles/config/agents/skills`
- `~/.claude/agents` → `~/.dotfiles/config/claude/agents`
- `~/.codex/AGENTS.md` → `~/.dotfiles/config/agents/AGENTS.md`
- `~/.agents/skills` → `~/.dotfiles/config/agents/skills`

## MCP servers

Claude Code MCP servers are declared in `config/claude/settings.json` (tracked in this repo) using bare command names — no absolute paths — so they work cross-platform as long as the binary is in `$PATH`.

Codex MCP servers are configured in `~/.codex/config.toml`. To avoid clobbering host-specific Codex settings (for example `projects.*.trust_level`), `setup.sh` manages Codex MCP entries via `codex mcp add` instead of symlinking a repo-managed `config.toml`.

`setup.sh` installs required MCP server binaries via `uv tool install`.

| Server | Command | Installed by |
|---|---|---|
| `arxiv` | `arxiv-mcp-server` | `uv tool install arxiv-mcp-server` |
