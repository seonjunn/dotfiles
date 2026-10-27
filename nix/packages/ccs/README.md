# CCS

`nix/home/agents.nix` installs this package in the common Home Manager profile.
`package.json` pins the CCS release; `package-lock.json` pins its npm dependencies.
The published bundle already contains the CLI and dashboard. Npm lifecycle scripts
are disabled because CCS install/uninstall hooks can change account data in `~/.ccs`.

To update, change the CCS version in `package.json`, regenerate the lock with
`npm install --package-lock-only --ignore-scripts --no-audit --no-fund` here, and
update `npmDepsHash` in `default.nix`. Build on Linux and macOS before rollout;
check CLI startup and bcrypt loading (the dashboard uses its native module).

The standalone bootstrap reads the same release from `package.json`. On Home
Manager machines, apply the Home Manager configuration instead of installing a
second global npm copy. Accounts, credentials, profiles and conversations are
owned by CCS and are not part of this package.
