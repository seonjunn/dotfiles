# Android device tools: adb and fastboot from nixpkgs, adb-shell from its source (flake input).
# Opt-in (homeModules.android). Builds (SDK, NDK) are not here.
{ adb-shell }:
{ pkgs, ... }:
let
  pk = builtins.fromTOML (builtins.readFile ../data/packages.toml);
  # android-tools comes from unstable (packages.toml [unstable]): the newest release (stable lags a major behind).
  # Every adb release so far speaks protocol 41, which the shared lab adb servers on 127.0.0.1:5037 also speak; a
  # client with another protocol would kill such a server for every user on that machine, so check `adb version`
  # on a bump.
  # the script finds startup.sh next to itself, so run it from the fetched tree
  adbShell = pkgs.writeShellScriptBin "adb-shell" ''exec ${pkgs.bash}/bin/bash ${adb-shell}/adb-shell.sh "$@"'';
in
{
  home.packages = map (n: pkgs.${n}) pk.android.names ++ [ adbShell ];
}
