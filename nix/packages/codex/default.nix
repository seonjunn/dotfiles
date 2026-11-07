{
  lib,
  buildNpmPackage,
  nodejs_24,
  makeWrapper,
}:
let
  manifest = builtins.fromJSON (builtins.readFile ./package.json);
  # `codex update` would reinstall from npm over a read-only store path. Hand it to codex-nix-update when the
  # machine has one (a config that pins this package can provide it), else explain where the version lives.
  updateGuard = ''
    if [ "''${1-}" = update ]; then
      shift
      if command -v codex-nix-update >/dev/null 2>&1; then exec codex-nix-update "$@"; fi
      echo "codex: this Codex is pinned by Nix (dotfiles nix/packages/codex); update it there (see its README), not with npm." >&2
      exit 1
    fi
    # Codex's own update notice says `npm install -g`, which cannot update this copy (set
    # check_for_update_on_startup = false). A config that pins this package can leave a one-line
    # notice here instead (e.g. "new release, run codex update"); show it when Codex starts.
    if [ -t 2 ] && [ -s "''${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/notice/codex" ]; then
      cat "''${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/notice/codex" >&2
    fi
  '';
in
buildNpmPackage {
  pname = "codex";
  version = manifest.dependencies."@openai/codex";
  src = lib.cleanSource ./.;
  nodejs = nodejs_24;
  npmDepsHash = "sha256-QTm3H+EdJ2qTCsAXqx/GytG+LR+/0wtHCCCP06U6McU=";
  npmFlags = [ "--ignore-scripts" ];
  dontNpmBuild = true;
  nativeBuildInputs = [ makeWrapper ];
  installPhase = ''
    runHook preInstall
    mkdir -p "$out/share/codex" "$out/bin"
    cp -r node_modules "$out/share/codex/"
    makeWrapper ${nodejs_24}/bin/node "$out/bin/codex" \
      --run ${lib.escapeShellArg updateGuard} \
      --add-flags "$out/share/codex/node_modules/@openai/codex/bin/codex.js"
    runHook postInstall
  '';
  meta = {
    description = "Codex CLI";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "codex";
  };
}
