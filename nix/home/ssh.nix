# ssh client defaults. Hosts are added by your own config as programs.ssh.settings.<name>.
# ~/.ssh/config is generated (read-only). Tools add files under ~/.ssh/config.d/*.conf;
# machine-only exceptions go to ~/.ssh/config.d/local.conf. One Include with one pattern: VS Code Remote-SSH
# gives up on the whole file (no host list) when an Include line has more than one value.
{ lib, pkgs, ... }:
{
  # macOS /usr/bin/sftp is built without libedit (no tab completion); take sftp alone from nixpkgs
  # and keep Apple's ssh.
  home.packages = lib.optional pkgs.stdenv.isDarwin (
    pkgs.runCommand "sftp-libedit" { } "mkdir -p $out/bin; ln -s ${pkgs.openssh}/bin/sftp $out/bin/sftp"
  );

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    includes = [ "config.d/*.conf" ];
    settings."*" = {
      AddKeysToAgent = "yes"; # a key used once stays in the agent
      ServerAliveInterval = 30;
      ControlMaster = "auto"; # reuse one connection per host
      # Directly in ~/.ssh, not a subdirectory: this file is also bind-mounted alone into dev containers, where
      # nothing creates a directory, and ssh fails every connection when the ControlPath directory is missing.
      # Nothing here may depend on a path that only Home Manager activation creates.
      ControlPath = "~/.ssh/cm-%C";
      ControlPersist = "10m";
    };
  };

  # Which agent: hosts that forward it use `ForwardAgent ~/.ssh/agent.sock` (written by the machine's own
  # config), so a ControlMaster opened from a shell without $SSH_AUTH_SOCK still forwards the right agent.
  # The machine decides what the path points to: its own agent where the keys are, the newest forwarded one
  # on a server (server.nix). Shells and agent clients (ssh-add, git, old tmux panes) use the same path.
  programs.fish.shellInit = ''
    set -gx SSH_AUTH_SOCK $HOME/.ssh/agent.sock
  '';
}
