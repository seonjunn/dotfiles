# git and delta. Settings from nix/data/git.toml. HM writes ~/.config/git/config (read-only);
# ~/.gitconfig is left to tools that write to it (gh's credential helper). Identity: set
# programs.git.settings.user in your own config. Machine-only values: ~/.gitconfig.local.
{ ... }:
let
  git = builtins.fromTOML (builtins.readFile ../data/git.toml);
in
{
  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = git.settings;
    includes = [ { path = "~/.gitconfig.local"; } ];
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = git.delta;
  };
}
