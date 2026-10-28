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
  pname = "codex";
  version = manifest.dependencies."@openai/codex";
  src = lib.cleanSource ./.;
  nodejs = nodejs_24;
  npmDepsHash = "sha256-phmgR6MEtm5ykqsP11Np8ZAow5sZ8oxIt1PYAKoocss=";
  npmFlags = [ "--ignore-scripts" ];
  dontNpmBuild = true;
  nativeBuildInputs = [ makeWrapper ];
  installPhase = ''
    runHook preInstall
    mkdir -p "$out/share/codex" "$out/bin"
    cp -r node_modules "$out/share/codex/"
    makeWrapper ${nodejs_24}/bin/node "$out/bin/codex" \
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
