#!/usr/bin/env bash
# The dev container Feature `personal`, run as root at image build time (cached with the image). Attached only by
# dotfiles bin/devc. The tools come one of two ways, never both:
# - nixProfile set (a Linux docker host with Nix; bin/devc also mounts the host's /nix and the user's Nix
#   profile read-only): the host's current Home Manager profile goes in PATH after the image's own dirs, so the
#   project's tools (git, cmake, node, ...) win and mine fill in what the image lacks. Nothing is installed.
# - otherwise (malphite's OrbStack): release binaries at the versions given as options, which dotfiles
#   nix/home/devcontainer.nix reads from the packages Home Manager installs, so no version is written down twice.
# Either way: fish as the login shell, an sshd that runs one connection per `docker exec` (no port), and a start
# script (the entrypoint) that starts the project's Orca server. Per-project state lives in ~/.local, which devc
# bind-mounts from the docker host; nothing here is written under the home directory.
set -euo pipefail

PREFIX=/opt/personal
HOME_EXPECTED=/home/vscode # where the mounts land (devcontainer-feature.json, bin/devc)
say() { echo "[personal] $*"; }
die() { echo "[personal] error: $*" >&2; exit 1; }

# shellcheck disable=SC1091
. /etc/os-release 2>/dev/null || die "no /etc/os-release: this Feature supports Debian and Ubuntu images"
case " ${ID:-} ${ID_LIKE:-} " in
	*" debian "* | *" ubuntu "*) ;;
	*) die "this Feature supports Debian and Ubuntu images, not ${PRETTY_NAME:-${ID:-unknown}}" ;;
esac
case "$(uname -m)" in
	x86_64) A=x86_64 GOARCH=amd64 GUMARCH=x86_64 NODEARCH=x64 LIBC=musl ;;
	aarch64 | arm64) A=aarch64 GOARCH=arm64 GUMARCH=arm64 NODEARCH=arm64 LIBC=gnu ;;
	*) die "this Feature supports x86_64 and aarch64, not $(uname -m)" ;;
esac
[ "${_REMOTE_USER_HOME:-}" = "$HOME_EXPECTED" ] ||
	die "the mounts land under $HOME_EXPECTED, but the remote user is ${_REMOTE_USER:-?} with home ${_REMOTE_USER_HOME:-?}"
USER_NAME=$_REMOTE_USER
USER_GROUP=$(id -gn "$USER_NAME")
NIXPROFILE=${NIXPROFILE:-}

if [ -z "$NIXPROFILE" ]; then
	missing=""
	for opt in FISH TMUX FZF RIPGREP GUM EZA ZOXIDE UV NODE CODEX CCS; do
		[ -n "${!opt:-}" ] || missing="$missing ${opt,,}"
	done
	[ -z "$missing" ] || die "no release given for:$missing. bin/devc passes them from ~/.config/devc/config.json (dotfiles nix/home/devcontainer.nix)"
fi

installed() { dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q 'install ok installed'; }
apt_add() { # packages not installed yet; prints the ones it installed
	local p new=()
	for p in "$@"; do installed "$p" || new+=("$p"); done
	[ ${#new[@]} -gt 0 ] || return 0
	[ -n "$(ls -A /var/lib/apt/lists 2>/dev/null | grep -v '^lock$\|^partial$')" ] || apt-get update -q >&2
	DEBIAN_FRONTEND=noninteractive apt-get install -y -q --no-install-recommends "${new[@]}" >&2
	echo "${new[*]}"
}
# git and python3: bootstrap/container.sh needs them before PATH has anything else; sshd: see below
apt_add ca-certificates curl git python3 openssh-server xz-utils >/dev/null
# en_US.UTF-8, which my shells export as LC_ALL: images like ubuntu:22.04 lack it, and bash warns at every start.
# Debian generates what /etc/locale.gen lists; Ubuntu also takes the name as an argument.
if ! locale -a 2>/dev/null | grep -qix 'en_us.utf-\?8'; then
	say "locale en_US.UTF-8"
	apt_add locales >/dev/null
	sed -i 's/^# *\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen
	locale-gen en_US.UTF-8 >/dev/null
fi

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
fetch() { curl -fsSL --retry 3 -o "$2" "$1" || die "download failed: $1"; }

find /usr/local/bin -maxdepth 1 -lname "$PREFIX/*" -delete
rm -rf "$PREFIX"
install -d "$PREFIX/bin"

if [ -n "$NIXPROFILE" ]; then
	say "tools from the docker host's Nix profile $NIXPROFILE"
	ln -sfn "$NIXPROFILE" "$PREFIX/nix-profile" # last in PATH (containerEnv); resolves once devc has mounted it
	FISH_BIN=$PREFIX/nix-profile/bin/fish
else
	# One row per release binary: name | archive URL | programs taken from the archive.
	gh=https://github.com
	TOOLS=(
		"fish|$gh/fish-shell/fish-shell/releases/download/$FISH/fish-$FISH-linux-$A.tar.xz|fish"
		"fzf|$gh/junegunn/fzf/releases/download/v$FZF/fzf-$FZF-linux_$GOARCH.tar.gz|fzf"
		"ripgrep|$gh/BurntSushi/ripgrep/releases/download/$RIPGREP/ripgrep-$RIPGREP-$A-unknown-linux-$LIBC.tar.gz|rg"
		"gum|$gh/charmbracelet/gum/releases/download/v$GUM/gum_${GUM}_Linux_$GUMARCH.tar.gz|gum"
		"eza|$gh/eza-community/eza/releases/download/v$EZA/eza_$A-unknown-linux-$LIBC.tar.gz|eza"
		"zoxide|$gh/ajeetdsouza/zoxide/releases/download/v$ZOXIDE/zoxide-$ZOXIDE-$A-unknown-linux-musl.tar.gz|zoxide"
		"uv|$gh/astral-sh/uv/releases/download/$UV/uv-$A-unknown-linux-gnu.tar.gz|uv uvx"
	)
	for row in "${TOOLS[@]}"; do
		IFS='|' read -r name url progs <<<"$row"
		say "$name"
		d="$TMP/$name"
		mkdir -p "$d"
		fetch "$url" "$d/archive"
		tar -xf "$d/archive" -C "$d"
		for p in $progs; do
			f=$(find "$d" -type f -name "$p" | head -1)
			[ -n "$f" ] || die "$name: no $p in $url"
			install -m 0755 "$f" "$PREFIX/bin/$p"
		done
	done

	# tmux publishes no binaries: build it, statically, so the build packages can go again.
	say "tmux $TMUX (from source)"
	build=$(apt_add build-essential bison pkg-config libevent-dev libncurses-dev)
	fetch "https://github.com/tmux/tmux/releases/download/$TMUX/tmux-$TMUX.tar.gz" "$TMP/tmux.tar.gz"
	tar -xzf "$TMP/tmux.tar.gz" -C "$TMP"
	(cd "$TMP/tmux-$TMUX" && ./configure -q --enable-static --prefix="$PREFIX/tmux" >/dev/null && make -s -j"$(nproc)" >/dev/null 2>&1 && make -s install >/dev/null) ||
		die "tmux $TMUX did not build"
	ln -sfn "$PREFIX/tmux/bin/tmux" "$PREFIX/bin/tmux"
	# shellcheck disable=SC2086
	[ -z "$build" ] || DEBIAN_FRONTEND=noninteractive apt-get purge -y -q --auto-remove $build >/dev/null

	say "node $NODE"
	install -d "$PREFIX/node"
	fetch "https://nodejs.org/dist/v$NODE/node-v$NODE-linux-$NODEARCH.tar.xz" "$TMP/node.tar.xz"
	tar -xJf "$TMP/node.tar.xz" -C "$PREFIX/node" --strip-components=1

	# npm lifecycle scripts stay off, as in Home Manager (dotfiles nix/packages): they could change ~/.ccs or ~/.codex.
	say "codex $CODEX, ccs $CCS"
	PATH="$PREFIX/node/bin:$PATH" npm install -g --prefix "$PREFIX/npm" --cache "$TMP/npm-cache" \
		--ignore-scripts --no-audit --no-fund "@openai/codex@$CODEX" "@kaitranntt/ccs@$CCS"
	# Each command runs on this node, never on a project's own (maybe older) node first in PATH.
	for l in "$PREFIX"/npm/bin/*; do
		printf '#!/bin/sh\nexec %s %s "$@"\n' "$PREFIX/node/bin/node" "$(readlink -f "$l")" >"$PREFIX/bin/$(basename "$l")"
		chmod 0755 "$PREFIX/bin/$(basename "$l")"
	done

	for p in "$PREFIX"/bin/*; do
		ln -sfn "$p" "/usr/local/bin/$(basename "$p")"
	done
	# node, npm, npx: a project's own node stays first; these are only a fallback (MCP servers start with npx).
	for p in node npm npx; do
		if [ "$(readlink "/usr/local/bin/$p" 2>/dev/null)" = "$PREFIX/node/bin/$p" ] || ! command -v "$p" >/dev/null 2>&1; then
			ln -sfn "$PREFIX/node/bin/$p" "/usr/local/bin/$p"
		fi
	done

	export HOME="$TMP/home" CCS_HOME="$TMP/home/.ccs" # --version may create state dirs (ccs does)
	check() { # program (in $PREFIX/bin, or a path), release: fail the build when a download is not the release asked for
		local bin=$1 out
		[[ $bin == /* ]] || bin=$PREFIX/bin/$bin
		out=$("$bin" "${3:---version}" 2>&1) || die "$1 --version failed: $out"
		grep -qF -- "$2" <<<"$out" || die "$1 is not $2: $out"
	}
	check fish "$FISH"
	check tmux "$TMUX" -V
	check fzf "$FZF"
	check rg "$RIPGREP"
	check gum "$GUM"
	check eza "$EZA"
	check zoxide "$ZOXIDE"
	check uv "$UV"
	check "$PREFIX/node/bin/node" "$NODE"
	check codex "$CODEX"
	check ccs "$CCS"
	FISH_BIN=$PREFIX/bin/fish
fi

# fish is the login shell, for ssh logins as well (Claude Code is installed per project by bootstrap/container.sh).
grep -qxF "$FISH_BIN" /etc/shells || echo "$FISH_BIN" >>/etc/shells
usermod -s "$FISH_BIN" "$USER_NAME"

# sshd for one connection at a time over stdin/stdout, started as root by `docker exec -i ... sshd-stdio` (devc
# stdio). No port is opened, so the container needs no published port and no listener on the docker host. The host
# key is the project's own (~/.local, bind-mounted per project): kept across rebuilds, never shared.
state="$HOME_EXPECTED/.local/state/sshd"
curl -fsSL --retry 3 https://github.com/seonjunn.keys >"$PREFIX/authorized_keys" || die "could not fetch the public keys from GitHub"
[ -s "$PREFIX/authorized_keys" ] || die "GitHub lists no public keys for seonjunn"
chmod 0644 "$PREFIX/authorized_keys"
cat >"$PREFIX/sshd_config" <<EOF
HostKey $state/ssh_host_ed25519_key
PubkeyAuthentication yes
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin no
UsePAM yes
AllowUsers $USER_NAME
AuthorizedKeysFile .ssh/authorized_keys $PREFIX/authorized_keys $state/authorized_keys
AllowAgentForwarding yes
Subsystem sftp internal-sftp
EOF
# The project's state files are the user's (they sit in a directory of the docker host's user).
cat >"$PREFIX/state" <<EOF
#!/bin/sh
# make this project's state dirs and sshd host key, as the user
runuser -u $USER_NAME -- sh -c 'umask 077; mkdir -p "$state" "$HOME_EXPECTED/.local/state/orca" &&
	{ [ -f "$state/ssh_host_ed25519_key" ] || ssh-keygen -q -t ed25519 -N "" -f "$state/ssh_host_ed25519_key"; }'
EOF
# sshd gives a session a fixed environment; pass the container's PATH (dab's, then the image's, then mine) and
# DAB_HOME (containerEnv).
cat >"$PREFIX/bin/sshd-stdio" <<EOF
#!/bin/sh
set -e
[ "\$(id -u)" = 0 ] || { echo "sshd-stdio runs as root (docker exec -u root)" >&2; exit 1; }
# sshd refuses a world-writable privsep dir, and docker exec may start with umask 0 (OrbStack does)
umask 022
mkdir -p /run/sshd
chmod 0755 /run/sshd
$PREFIX/state
exec /usr/sbin/sshd -i -f $PREFIX/sshd_config -o "SetEnv=PATH=\$PATH DAB_HOME=\$DAB_HOME"
EOF
chmod 0755 "$PREFIX/state" "$PREFIX/bin/sshd-stdio"
# Each ssh login points ~/.ssh/agent.sock at the agent it forwarded, as the servers do (dotfiles server.nix): shells
# and tmux panes use that fixed path (config/fish/config.fish), so they keep working after the session that
# started them ends. sshd runs this file for every session, whatever the user's shell.
if [ ! -e /etc/ssh/sshrc ] || grep -q 'dotfiles Feature personal' /etc/ssh/sshrc; then
	cat >/etc/ssh/sshrc <<'EOF'
# from the dotfiles Feature personal: ~/.ssh/agent.sock -> the agent this session forwarded
if [ -S "${SSH_AUTH_SOCK:-}" ]; then ln -sfn "$SSH_AUTH_SOCK" "$HOME/.ssh/agent.sock"; fi
EOF
else
	say "kept the image's own /etc/ssh/sshrc: ~/.ssh/agent.sock is not repointed on ssh login"
fi

# Container start (the entrypoint, root, every start): the project's state, and its Orca server (orcad) when the
# project has one installed in ~/.local/opt/orcad. orcad keeps its data, lock and log in the project's
# ~/.local/state (orca-hub's defaults), so two containers never share them.
orca=$HOME_EXPECTED/.local/state/orca
if [ -n "$NIXPROFILE" ]; then
	# ~/.ssh/config: the host's, from its current Home Manager generation (read-only, mounted by devc), unless the
	# project mounts one itself. Without Nix, bin/devc binds the host's file instead.
	sshconfig="ln -sfn $(dirname "$NIXPROFILE")/home-manager/home-files/.ssh/config $HOME_EXPECTED/.ssh/config"
	sshconfig="grep -qs ' $HOME_EXPECTED/.ssh/config ' /proc/mounts || runuser -u $USER_NAME -- $sshconfig"
else
	sshconfig=:
fi
cat >"$PREFIX/start" <<EOF
#!/bin/sh
umask 022
$PREFIX/state
$sshconfig
hub=$HOME_EXPECTED/.local/opt/orcad/orca-hub
status=/run/personal-orcad
if [ -x "\$hub" ]; then
	# nothing runs yet in a container that is starting: a lock in the project's state is from an orcad that is gone
	rm -f "$orca/orcad.lock"
	# The port is the project's declared one (leblanc's tunnel points at it), never another: without one, or when
	# it is taken, orcad stays down and says why (docker logs and \$status, which devc up prints).
	port=\$(cat $PREFIX/orcad-port 2>/dev/null)
	if [ -z "\$port" ]; then
		echo "orcad not started: no port declared for this project (infra data/orca.toml)" | tee \$status >&2
	elif ! python3 -c 'import socket, sys; socket.socket().bind(("127.0.0.1", int(sys.argv[1])))' "\$port" 2>/dev/null; then
		echo "orcad not started: port \$port is taken (another container on the host's network?)" | tee \$status >&2
	else
		echo "orcad starting on 127.0.0.1:\$port" >\$status
		# as the user, the log too: files in ~/.local belong to the docker host's user
		runuser -u $USER_NAME -- env HOME=$HOME_EXPECTED sh -c '"\$0" start >>"$orca/start.log" 2>&1' "\$hub" &
	fi
fi
exec "\$@"
EOF
chmod 0755 "$PREFIX/start"
# What orca-hub reads by default (infra hosts/florence/dike-orca/orca-hub), also when run by hand.
echo "${ORCADPORT:-}" >"$PREFIX/orcad-port"
echo "${WORKSPACEFOLDER:-}" >"$PREFIX/workspace"

# GitHub's host keys, from its API over HTTPS, so the first git over ssh in a fresh container needs no prompt.
if ! grep -qs '^github.com ' /etc/ssh/ssh_known_hosts; then
	curl -fsSL --retry 3 https://api.github.com/meta |
		python3 -c 'import json, sys; print("\n".join("github.com " + k for k in json.load(sys.stdin)["ssh_keys"]))' \
			>>/etc/ssh/ssh_known_hosts || die "could not fetch GitHub's ssh host keys"
fi

# Mount points owned by the user, so a new empty volume starts out writable by them.
install -d -o "$USER_NAME" -g "$USER_GROUP" "$HOME_EXPECTED/.agents" "$HOME_EXPECTED/.config" \
	"$HOME_EXPECTED/.local" "$HOME_EXPECTED/.cache"
install -d -m 0700 -o "$USER_NAME" -g "$USER_GROUP" "$HOME_EXPECTED/.ssh"

rm -rf /var/lib/apt/lists/*
{
	if [ -n "$NIXPROFILE" ]; then
		echo "tools=$NIXPROFILE"
	else
		echo "tools=image"
		for opt in FISH TMUX FZF RIPGREP GUM EZA ZOXIDE UV NODE CODEX CCS; do echo "${opt,,}=${!opt}"; done
	fi
} >"$PREFIX/versions"
say "done: $(tr '\n' ' ' <"$PREFIX/versions")"
