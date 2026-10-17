# My own commands as one package in the Home Manager profile, next to the Nix packages.
# PATH puts the profile first (fish.nix), so everything I declare (Nix packages and these scripts) wins over
# hand-installed tools (~/.local/bin, ~/bin, npm globals) and the system. One profile also means a name taken
# twice is a build error ("collision between ..."), not a silent shadow: trash-cli's trash-rm once ran instead
# of our rm script because the two sat in different PATH dirs.
#
# dotfiles.scripts.<name> = the file to run. A Nix path is pinned like the rest of dotfiles; a string path is
# read live (desktop liveFrom, infra tools on leblanc). Each command is a small wrapper that execs the target,
# so a script still finds its own tree (e.g. ../config) from its real location.
{ config, lib, pkgs, ... }:
let
  cfg = config.dotfiles.scripts;
  root = ../..; # the whole tree, so scripts find ../config
  # A Nix path becomes its own store path holding just that file (and a dependency of the profile). toString
  # would keep pointing into the caller's flake source, which is not copied to other machines (and copying it
  # would put a private repo on a shared server).
  copied = t: if builtins.isPath t then "${t}" else t;
in
{
  options.dotfiles.scripts = lib.mkOption {
    type = lib.types.attrsOf (lib.types.either lib.types.path lib.types.str);
    default = { };
    description = "Commands to put in the Home Manager profile: name -> file to run.";
  };

  config = {
    dotfiles.scripts = lib.mapAttrs (n: _: "${root}/bin/${n}")
      (lib.filterAttrs (n: t: t == "regular" && !lib.hasPrefix "." n) (builtins.readDir (root + "/bin")));

    home.packages = lib.mkIf (cfg != { }) [
      (pkgs.runCommand "my-scripts" { } (''
        mkdir -p $out/bin
      '' + lib.concatStrings (lib.mapAttrsToList (n: target: ''
        printf '#!/bin/sh\nexec %s "$@"\n' ${lib.escapeShellArg (copied target)} > $out/bin/${lib.escapeShellArg n}
        chmod +x $out/bin/${lib.escapeShellArg n}
      '') cfg)))
    ];
  };
}
