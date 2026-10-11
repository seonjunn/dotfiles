# Command-line tools. Add a tool here only after removing its other copies (cargo, ~/bin, /usr/local, apt).
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    fd
    nixfmt
  ];
}
