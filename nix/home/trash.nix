# `rm` typed in the shell moves files to the trash (bin/trash-rm); scripts and programs keep the real rm.
# Real deletion: `command rm`. Items older than 30 days are emptied automatically.
#   Linux: trash-cli, freedesktop trash (~/.local/share/Trash, shared with the file manager); restore: trash-restore
#   macOS: /usr/bin/trash, Finder trash; restore: Finder's "Put Back"
{ lib, pkgs, ... }:
let
  trashRm = "${../..}/bin/trash-rm";
in
lib.mkMerge [
  {
    # `rm` itself is an abbr in nix/data/shell.toml. Under sudo the absolute path is needed (sudo's PATH has no
    # Nix profile); root's files go to root's trash (`sudo trash-restore`).
    programs.fish.shellAbbrs.sudo-rm = {
      regex = "^rm$";
      command = "sudo";
      expansion = trashRm;
    };
  }
  (lib.mkIf pkgs.stdenv.isLinux {
    home.packages = [ pkgs.trash-cli ];
    systemd.user.services.trash-empty = {
      Unit.Description = "Empty trash items older than 30 days";
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.trash-cli}/bin/trash-empty -f 30";
      };
    };
    systemd.user.timers.trash-empty = {
      Unit.Description = "Empty old trash items daily";
      Timer = {
        OnCalendar = "daily";
        Persistent = true;
      };
      Install.WantedBy = [ "timers.target" ];
    };
  })
  (lib.mkIf pkgs.stdenv.isDarwin {
    targets.darwin.defaults."com.apple.finder".FXRemoveOldTrashItems = true;
  })
]
