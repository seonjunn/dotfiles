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
| `fish/` | Fish shell config (symlinked to `~/.config/fish`) |
| `vim/` | Vim config (symlinked to `~/.vimrc`) |
| `bash/` | Bash config |
| `claude/` | Claude Code settings, commands, agents |
| `agents/` | Shared agent prompt (`AGENTS.md`) and skills |
| `ipython/` | IPython profile |
| `setup.sh` | Full bootstrap: installs packages, clones repo, creates symlinks; grants passwordless sudo when run via `sudo bash` |

## Bootstrap order

1. Run `setup.sh` via `sudo bash` (once, on a fresh machine, to grant passwordless sudo)
2. Run `setup.sh` as the target user

## Symlinks created by setup.sh

- `~/.tmux.conf` → `~/.dotfiles/tmux/.tmux.conf`
- `~/.vimrc` → `~/.dotfiles/vim/.vimrc`
- `~/.config/fish` → `~/.dotfiles/fish`
- `~/.ipython/profile_default` → `~/.dotfiles/ipython/profile_default`
- `~/.claude/CLAUDE.md` → `~/.dotfiles/claude/CLAUDE.md`
- `~/.claude/settings.json` → `~/.dotfiles/claude/settings.json`
- `~/.claude/commands` → `~/.dotfiles/claude/commands`
- `~/.claude/skills` → `~/.dotfiles/agents/skills`
- `~/.claude/agents` → `~/.dotfiles/claude/agents`
- `~/.codex/AGENTS.md` → `~/.dotfiles/agents/AGENTS.md`
- `~/.agents/skills` → `~/.dotfiles/agents/skills`

## MCP servers

Claude Code MCP servers are declared in `claude/settings.json` (tracked in this repo) using bare command names — no absolute paths — so they work cross-platform as long as the binary is in `$PATH`.

Codex MCP servers are configured in `~/.codex/config.toml`. To avoid clobbering host-specific Codex settings (for example `projects.*.trust_level`), `setup.sh` manages Codex MCP entries via `codex mcp add` instead of symlinking a repo-managed `config.toml`.

`setup.sh` installs required MCP server binaries via `uv tool install`.

| Server | Command | Installed by |
|---|---|---|
| `arxiv` | `arxiv-mcp-server` | `uv tool install arxiv-mcp-server` |
