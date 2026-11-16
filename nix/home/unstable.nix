# Packages taken from nixpkgs-unstable (nix/data/packages.toml [unstable]) instead of the stable channel.
# An overlay, so every reader of pkgs.<name> (home.packages, uv.nix, devcontainer.nix's releases) sees the
# version that is installed. The flake builds this with its nixpkgs-unstable input.
{ nixpkgs-unstable }:
{ lib, ... }:
let
  pk = builtins.fromTOML (builtins.readFile ../data/packages.toml);
in
{
  key = "dotfiles-unstable"; # imported by base, server and android; once is enough
  nixpkgs.overlays = [
    (_: prev:
      let unstable = import nixpkgs-unstable { inherit (prev.stdenv.hostPlatform) system; };
      in lib.genAttrs pk.unstable.names (n: unstable.${n}))
  ];
}
