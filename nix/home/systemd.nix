# Linux (not NixOS): drive user units with the machine's own systemctl.
# HM defaults to the systemctl from Nix, which older system systemd rejects (Ubuntu 22.04's 249, 20.04's 245:
# "Failed to connect to user scope bus"), so units were silently not started. The machine's own systemctl
# always matches its running systemd. /bin/systemctl exists on every distro: /bin is a link to /usr/bin
# on usr-merged systems and the real location on the others.
# HM's "is user systemd running" check ignores systemctlPath and looks systemctl up in /usr/bin plus the
# activation PATH, which misses non-usr-merged systems; the shim below covers that (harmless elsewhere).
{ lib, pkgs, ... }:
lib.mkIf pkgs.stdenv.isLinux {
  systemd.user.systemctlPath = "/bin/systemctl";
  home.extraActivationPath = [ (pkgs.writeShellScriptBin "systemctl" ''exec /bin/systemctl "$@"'') ];
}
