# Codex CLI

The common Home Manager profile installs the exact npm release in `package.json`.
`package-lock.json` and `npmDepsHash` pin the platform package and its native binary.
The wrapper calls the Nix Node and the published Codex entrypoint. Codex's
`~/.codex` authentication and sessions remain outside the store.

To update: change the version in `package.json`, run
`npm install --package-lock-only --ignore-scripts --no-audit --no-fund` here,
replace `npmDepsHash` with the hash reported by a test build, and validate the
Linux and macOS CLIs. The non-HM bootstrap uses the same version.
