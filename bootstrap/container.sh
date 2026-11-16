#!/usr/bin/env bash
# Personal setup inside a dev container without Nix. The project's image brings the system and its
# tools; this brings the settings and the pinned agent CLIs. A project's git-ignored post-create hook
# clones this repo to ~/.dotfiles and runs this file. Every step checks the current state first, so it
# is safe to rerun, also on volumes an earlier container already filled.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export DOTFILES_DIR="$DOTFILES"
# A volume shared by the user's containers. Agent state lives there, so a rebuild keeps the sessions.
AGENTS="$HOME/.agents"
AGENT_HOMES=(claude codex ccs grok claude.json)

say() { echo "[container] $*"; }
is_empty_dir() { [ -d "$1" ] && [ ! -L "$1" ] && [ -z "$(ls -A "$1")" ]; }

# ~/.<name> becomes a link to ~/.agents/<name>. Data already at ~/.<name> is moved, never deleted.
link_agent_home() {
	local link="$HOME/.$1" target="$AGENTS/$1"
	[ -L "$link" ] && [ "$(readlink "$link")" = "$target" ] && return 0
	if [ -L "$link" ]; then
		rm "$link"
	elif is_empty_dir "$link"; then
		rmdir "$link"
	elif [ -e "$link" ]; then
		if is_empty_dir "$target"; then
			rmdir "$target"
		fi
		if [ ! -e "$target" ]; then
			say "moving $link into $target"
			mv "$link" "$target"
		elif [ -f "$link" ] && cmp -s "$link" "$target"; then
			rm "$link"
		else
			local aside
			aside="$target.pre-link.$(date +%Y%m%d%H%M%S)"
			say "$link and $target both hold data; moving $link to $aside"
			mv "$link" "$aside"
		fi
	fi
	if [ ! -e "$target" ]; then
		case "$1" in
			*.json) (umask 077; printf '{}\n' >"$target") ;;
			*) mkdir -p "$target" ;;
		esac
	fi
	ln -s "$target" "$link"
}

if [ -d "$AGENTS" ]; then
	for name in "${AGENT_HOMES[@]}"; do
		link_agent_home "$name"
	done
else
	say "no ~/.agents volume: agent state stays in this container and a rebuild loses it" >&2
fi

[ "$(git -C "$DOTFILES" remote get-url origin)" = https://github.com/seonjunn/dotfiles ] &&
	git -C "$DOTFILES" remote set-url origin git@github.com:seonjunn/dotfiles.git

# fish, tmux, fzf, ripgrep and gum: the settings need them and project images do not ship them.
if sudo -n true 2>/dev/null; then
	sudo bash "$DOTFILES/setup.sh" packages </dev/null
else
	say "no passwordless sudo: skipping fish, tmux, fzf, ripgrep, gum" >&2
fi
# The steps infra-update reruns in containers (codex ccs claude), plus the settings links. node and uv
# come in as their dependencies.
bash "$DOTFILES/setup.sh" git dotfiles ipython claude codex ccs </dev/null
