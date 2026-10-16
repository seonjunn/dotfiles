# tmux and vim. ~/.vimrc is config/vim/.vimrc (plugins under ~/.vim are vim's own state).
{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    mouse = true;
  };

  home.packages = map (n: pkgs.${n}) (builtins.fromTOML (builtins.readFile ../data/packages.toml)).editor.names;
  home.file.".vimrc".source = ../../config/vim/.vimrc;
}
