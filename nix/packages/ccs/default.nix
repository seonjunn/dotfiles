# npm's published bundle includes the compiled CLI and dashboard. Lock every dependency;
# never run its install hooks (they migrate ~/.ccs) while building or activating a home.
{
  lib,
  buildNpmPackage,
  nodejs_24,
  makeWrapper,
}:
let
  manifest = builtins.fromJSON (builtins.readFile ./package.json);
  # `ccs update` would have npm reinstall CCS over this read-only store path and fail (EACCES).
  # A machine that rolls out updates provides `ccs-nix-update`; anywhere else, say where updates come from.
  updateGuard = ''
    if [ "''${1-}" = update ] || [ "''${1-}" = --update ]; then
      shift
      if command -v ccs-nix-update >/dev/null 2>&1; then exec ccs-nix-update "$@"; fi
      echo "ccs: this CCS is pinned by Nix (dotfiles nix/packages/ccs); update it there (see its README), not with npm." >&2
      exit 1
    fi
  '';
in
buildNpmPackage {
  pname = "ccs";
  version = manifest.dependencies."@kaitranntt/ccs";
  src = lib.cleanSource ./.;
  nodejs = nodejs_24;
  npmDepsHash = "sha256-fmyMRsq9To0CNtHjanBhCxm1/KKgmbQSYCI7/U/6sVc=";
  npmFlags = [ "--ignore-scripts" ];
  dontNpmBuild = true;
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/lib" "$out/bin"
    cp -r node_modules "$out/lib/"
    for spec in \
      ccs:ccs.js \
      ccs-droid:bin/droid-runtime.js \
      ccsd:bin/droid-runtime.js \
      ccs-codex:bin/codex-runtime.js \
      ccsx:bin/codex-runtime.js \
      ccsxp:bin/ccsxp-runtime.js; do
      name=''${spec%%:*}
      extra=()
      if [ "$name" = ccs ]; then extra=(--run ${lib.escapeShellArg updateGuard}); fi
      makeWrapper ${nodejs_24}/bin/node "$out/bin/$name" "''${extra[@]}" \
        --add-flags "$out/lib/node_modules/@kaitranntt/ccs/dist/''${spec#*:}"
    done
    runHook postInstall
  '';

  meta = {
    description = "Claude Codex Switch: profiles and accounts for coding agents";
    homepage = "https://github.com/kaitranntt/ccs";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "ccs";
  };
}
