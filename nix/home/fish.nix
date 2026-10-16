# fish. config.fish keeps only what has to be fish code; PATH, environment, aliases and
# abbreviations are declared. Function files come from config/fish/functions.
# Machine-specific additions go to ~/.config/fish/local.fish (read last, never committed).
{ lib, pkgs, ... }:
let
  shell = builtins.fromTOML (builtins.readFile ../data/shell.toml);
in
{
  # PATH entries, highest priority first (node and npm globals: node.nix)
  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/bin"
    "${../..}/bin" # inside the whole tree: scripts find ../config from there
  ];

  home.sessionVariables = {
    EDITOR = "vim";
    TERM = "xterm-256color";
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
  };

  programs.fish = {
    enable = true;

    shellInit = ''
      # Nix's own fish reads /etc/fish/config.fish but not /etc/fish/conf.d/, where the Nix
      # installer put its PATH setup on non-NixOS. Source it here (it guards against double sourcing).
      if test -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
        source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
      end

      # secrets and machine env (fish syntax), never committed
      if test -f $HOME/.env
        source $HOME/.env
      end

      # macOS: Homebrew (casks and the few tools not in Nix) after Nix and the system
      if test -d /opt/homebrew/bin; and not contains -- /opt/homebrew/bin $PATH
        set -gx PATH $PATH /opt/homebrew/bin /opt/homebrew/sbin
      end

      # rustup toolchains (cargo, rustc), last in PATH
      if test -d $HOME/.cargo/bin; and not contains -- $HOME/.cargo/bin $PATH
        set -gx PATH $PATH $HOME/.cargo/bin
      end
    '';

    interactiveShellInit = ''
      set fish_greeting
      fish_vi_key_bindings
    '';

    shellInitLast = ''
      if test -f ~/.config/fish/local.fish
        source ~/.config/fish/local.fish
      end
    '';

    shellAliases = shell.aliases;
    shellAbbrs = shell.abbrs // lib.optionalAttrs pkgs.stdenv.isLinux shell.abbrs_linux;
  };

  # ~/.config/fish stays a real directory (fish writes fish_variables there); functions are linked one by one
  xdg.configFile."fish/functions" = {
    source = ../../config/fish/functions;
    recursive = true;
  };
}
