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
      # One agent path for every ssh, whatever $SSH_AUTH_SOCK the calling shell has: a ControlMaster opened from
      # a shell without it would otherwise forward no agent to every connection muxed through it. Hosts that
      # forward the agent use `ForwardAgent ~/.ssh/agent.sock`. The machine decides what the path points to:
      # its own agent where the keys are, the newest forwarded one on a server (server.nix).
      IdentityAgent = "~/.ssh/agent.sock";
      ServerAliveInterval = 30;
      ControlMaster = "auto"; # reuse one connection per host
      ControlPath = "~/.ssh/cm/%C";
      ControlPersist = "10m";
    };
  };

  # ssh does not create the ControlPath directory; without it every connection fails ("cannot bind")
  home.activation.sshControlDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p -m 700 "$HOME/.ssh/cm"
  '';

  # agent clients other than ssh (ssh-add, tools in an old tmux pane) find the same agent
  programs.fish.shellInit = ''
    set -gx SSH_AUTH_SOCK $HOME/.ssh/agent.sock
  '';
}
