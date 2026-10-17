# bash for machines whose login shell stays bash (lab servers: no chsh to a Nix fish there).
# Opt in with dotfiles.bash.enable: Home Manager then owns ~/.bashrc, ~/.profile and ~/.bash_profile,
# and an interactive login bash (ssh, tmux pane) hands over to fish.
{ config, lib, ... }:
{
  options.dotfiles.bash.enable = lib.mkEnableOption "Home Manager bash that execs fish on interactive login";

  config = lib.mkIf config.dotfiles.bash.enable {
    programs.bash = {
      enable = true;
      # Runs before the interactive check: `ssh host cmd` gets a non-interactive, non-login bash that reads
      # only ~/.bashrc, so without this it misses ~/.local/bin and the other session paths. Prints nothing.
      bashrcExtra = ''
        [ -r "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ] && . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
      '';
      # initExtra runs only in interactive shells. Login shells only: `bash -c` (scripts, Claude Code's
      # Bash tool, VS Code) must stay bash, and typing `bash` inside fish must give bash. And only without
      # a command: tools that read the login environment run `bash -lic 'cmd'`, which exec would swallow.
      initExtra = ''
        if shopt -q login_shell && [ -z "''${BASH_EXECUTION_STRING:-}" ]; then
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
