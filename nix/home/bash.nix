# bash for machines whose login shell stays bash (lab servers: no chsh to a Nix fish there).
# Opt in with dotfiles.bash.enable: Home Manager then owns ~/.bashrc, ~/.profile and ~/.bash_profile,
# and an interactive login bash (ssh, tmux pane) hands over to fish.
{ config, lib, ... }:
{
  options.dotfiles.bash.enable = lib.mkEnableOption "Home Manager bash that execs fish on interactive login";

  config = lib.mkIf config.dotfiles.bash.enable {
    programs.bash = {
      enable = true;
      # initExtra runs only in interactive shells. Login shells only: `bash -c` (scripts, Claude Code's
      # Bash tool, VS Code) must stay bash, and typing `bash` inside fish must give bash.
      initExtra = ''
        if shopt -q login_shell; then
          if [ -x "$HOME/.nix-profile/bin/fish" ]; then
            exec "$HOME/.nix-profile/bin/fish" -l
          elif command -v fish >/dev/null; then
            exec fish -l
          fi
        fi
      '';
    };
  };
}
