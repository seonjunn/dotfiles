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
      ControlPath = "~/.ssh/cm/%C";
      ControlPersist = "10m";
    };
  };
}
