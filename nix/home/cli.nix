# Command-line tools. Names come from nix/data/packages.toml.
{ pkgs, ... }:
let
  pk = builtins.fromTOML (builtins.readFile ../data/packages.toml);
in
{
  home.packages = map (n: pkgs.${n}) (pk.cli.names ++ pk.dev.names);

  # tools with shell integration: installed and wired into fish declaratively
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };
}
