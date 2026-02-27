# Dotfiles

Personal dotfiles for seonjunkim. Managed as a bare-style repo at `~/.dotfiles`, symlinked into place by `setup.sh`.

## Structure

| Path | Description |
|---|---|
| `fish/` | Fish shell config (symlinked to `~/.config/fish`) |
| `vim/` | Vim config (symlinked to `~/.vimrc`) |
| `bash/` | Bash config |
| `claude/` | Claude Code settings, commands, agents |
| `agents/` | Shared agent prompt (`AGENTS.md`) and skills |
| `ipython/` | IPython profile |
| `setup.sh` | Full bootstrap: installs packages, clones repo, creates symlinks |
| `bin/add-sudoer` | Pre-bootstrap root setup: grants passwordless sudo + creates home directories |

## Bootstrap order

1. Run `bin/add-sudoer` as root (once, on a fresh machine)
2. Run `setup.sh` as the target user

## Symlinks created by setup.sh

- `~/.vimrc` → `~/.dotfiles/vim/.vimrc`
- `~/.config/fish` → `~/.dotfiles/fish`
- `~/.ipython/profile_default` → `~/.dotfiles/ipython/profile_default`
- `~/.claude/CLAUDE.md` → `~/.dotfiles/agents/AGENTS.md`
- `~/.claude/settings.json` → `~/.dotfiles/claude/settings.json`
- `~/.claude/commands` → `~/.dotfiles/claude/commands`
- `~/.claude/skills` → `~/.dotfiles/agents/skills`
- `~/.claude/agents` → `~/.dotfiles/claude/agents`
- `~/.codex/AGENTS.md` → `~/.dotfiles/agents/AGENTS.md`
- `~/.agents/skills` → `~/.dotfiles/agents/skills`
