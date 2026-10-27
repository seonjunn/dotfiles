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
      makeWrapper ${nodejs_24}/bin/node "$out/bin/''${spec%%:*}" \
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
