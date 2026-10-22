# ssh client defaults. Hosts are added by your own config as programs.ssh.settings.<name>.
# ~/.ssh/config is generated (read-only). Tools add files under ~/.ssh/config.d/*.conf;
# machine-only exceptions go to ~/.ssh/config.d/local.conf. One Include with one pattern: VS Code Remote-SSH
# gives up on the whole file (no host list) when an Include line has more than one value.
{ ... }:
{
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
