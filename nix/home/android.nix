# Android device tools: adb and fastboot from nixpkgs, adb-shell from its source (flake input).
# Opt-in (homeModules.android). Builds (SDK, NDK) are not here.
{ adb-shell }:
{ pkgs, ... }:
let
  pk = builtins.fromTOML (builtins.readFile ../data/packages.toml);
  # the script finds startup.sh next to itself, so run it from the fetched tree
  adbShell = pkgs.writeShellScriptBin "adb-shell" ''exec ${pkgs.bash}/bin/bash ${adb-shell}/adb-shell.sh "$@"'';
in
{
  home.packages = map (n: pkgs.${n}) pk.android.names ++ [ adbShell ];
}
