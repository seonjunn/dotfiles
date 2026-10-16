# node (instead of nvm). Global npm packages go to a user prefix outside the Nix store, so
# `npm install -g` keeps working: ~/.local/share/npm-global.
{ pkgs, ... }:
{
  home.packages = map (n: pkgs.${n}) (builtins.fromTOML (builtins.readFile ../data/packages.toml)).runtime.names;

  home.sessionVariables.NPM_CONFIG_PREFIX = "$HOME/.local/share/npm-global";
  home.sessionPath = [ "$HOME/.local/share/npm-global/bin" ];
}
