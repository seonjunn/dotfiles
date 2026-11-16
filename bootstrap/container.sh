#!/usr/bin/env bash
# Personal settings inside a dev container, at create time. The Feature devcontainer/personal put my tools in the
# image (or the docker host's Nix profile first in PATH); bin/devc mounted the shared ~/.agents volume and the
# project's own ~/.local and ~/.cache. This links the agents' state into ~/.agents and the settings into this repo
# (project tool state finds ~/.local by env, e.g. DAB_HOME in the Feature's containerEnv). devc clones the repo to ~/.dotfiles and runs this file (the dotfiles settings in
# nix/home/devcontainer.nix). Every step checks the current state first, so it is safe to rerun, also on volumes
# and directories an earlier container already filled.
set -euo pipefail
PULL=0
[ "${1:-}" = --pull ] && PULL=1

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export DOTFILES_DIR="$DOTFILES"
# Shared by all my containers: agent sessions, so a rebuild or another project keeps them.
AGENTS="$HOME/.agents"
AGENT_HOMES=(claude codex ccs grok claude.json)

say() { echo "[container] $*"; }
is_empty_dir() { [ -d "$1" ] && [ ! -L "$1" ] && [ -z "$(ls -A "$1")" ]; }

# ~/.<name> becomes a link to <dir>/<name>. Data already at ~/.<name> is moved, never deleted.
link_home() {
	local link="$HOME/.$1" target="$2/$1"
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
		link_home "$name" "$AGENTS"
	done
else
	say "no ~/.agents volume: agent state stays in this container and a rebuild loses it" >&2
fi
[ "$(git -C "$DOTFILES" remote get-url origin)" = https://github.com/seonjunn/dotfiles ] &&
	git -C "$DOTFILES" remote set-url origin git@github.com:seonjunn/dotfiles.git

# Tools come from the Feature only. Without it the setup.sh steps below would install a second copy. When devc
# creates a container that is an error; on a later pull (--pull, infra-update's PULL_TARGETS) the container may
# simply predate the Feature: the links above are done, the rest waits for a rebuild.
skip() {
	if [ "$PULL" = 1 ]; then
		say "$1; settings steps skipped until then" >&2
		exit 0
	fi
	say "$1" >&2
	exit 1
}
if [ ! -f /opt/personal/versions ]; then
	skip "this image has no personal Feature (/opt/personal): rebuild the container with \`devc rebuild\`"
fi
# The npm CLIs are pinned here too (nix/packages). If the container's are older, the codex step would try to
# npm-install the new release over them.
tools=$(sed -n 's/^tools=//p' /opt/personal/versions)
stale=""
for pin in codex:@openai/codex ccs:@kaitranntt/ccs; do
	name=${pin%%:*}
	want=$(node -p "require('$DOTFILES/nix/packages/$name/package.json').dependencies['${pin#*:}']")
	if [ "$tools" = image ]; then
		have=$(sed -n "s/^$name=//p" /opt/personal/versions)
	else # the store path's name carries the version: /nix/store/<hash>-codex-0.167.0/bin/codex
		have=$(readlink -f "$(command -v "$name")" | sed -n "s|^/nix/store/[^-]*-$name-\([^/]*\)/.*|\1|p")
	fi
	[ "$want" = "$have" ] || stale="$stale $name ${have:-?} -> $want"
done
if [ -n "$stale" ]; then
	if [ "$tools" = image ]; then
		skip "the image is older than dotfiles:$stale. Rebuild the container (devc rebuild); ~/.agents and ~/.local stay"
	else
		skip "the docker host's Home Manager profile is older than dotfiles:$stale. Update the host (infra-update); the container follows it without a rebuild"
	fi
fi
bash "$DOTFILES/setup.sh" git dotfiles ipython claude codex </dev/null
