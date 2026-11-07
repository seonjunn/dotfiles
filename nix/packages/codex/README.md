# Codex CLI

The common Home Manager profile installs the exact npm release in `package.json`.
`package-lock.json` and `npmDepsHash` pin the platform package and its native binary.
The wrapper calls the Nix Node and the published Codex entrypoint. Codex's
`~/.codex` authentication and sessions remain outside the store.

`codex update` does not touch npm: the wrapper runs `codex-nix-update` if the
machine has that command (a config pinning this package can provide one that
does the update below), and otherwise says the version is pinned here.
Codex's own update notice suggests `npm install -g`, which cannot replace this
copy; with `check_for_update_on_startup = false` in its config, the wrapper
instead prints `~/.local/state/dotfiles/notice/codex` at an interactive start
if a config left one there.

To update: change the version in `package.json`, run
`npm install --package-lock-only --ignore-scripts --no-audit --no-fund` here,
replace `npmDepsHash` with the hash reported by a test build, and validate the
Linux and macOS CLIs. The non-HM bootstrap uses the same version.
