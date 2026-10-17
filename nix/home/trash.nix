# `rm` typed in the shell moves files to the trash (bin/rm-trash); scripts and programs keep the real rm.
# (Not "trash-rm": trash-cli has a trash-rm that permanently deletes matching items from the trash, and it came
# first in PATH, so `rm` silently did that instead of trashing; 2026-10-18.)
# Real deletion: `rm-fr` (expands to plain /bin/rm; add -rf yourself). Items older than dotfiles.trash.days (30) are emptied automatically
# (Linux; servers with full disks use fewer).
#   Linux: trash-cli, freedesktop trash (~/.local/share/Trash, shared with the file manager); restore: trash-restore
#   macOS: /usr/bin/trash, Finder trash; restore: Finder's "Put Back"
{ config, lib, pkgs, ... }:
let
  trashRm = "${../..}/bin/rm-trash";
  days = toString config.dotfiles.trash.days;
in
{
  options.dotfiles.trash.days = lib.mkOption {
    type = lib.types.ints.positive;
    default = 30;
    description = "Linux: trash items older than this many days are emptied daily (macOS Finder: always 30).";
  };

  config = lib.mkMerge [
    {
      # `rm` itself is an abbr in nix/data/shell.toml. Under sudo the absolute path is needed (sudo's PATH has no
      # Nix profile); root's files go to root's trash (`sudo trash-restore`).
      programs.fish.shellAbbrs = {
        sudo-rm = {
          regex = "^rm$";
          command = "sudo";
          expansion = trashRm;
        };
        # real rm, no options added; /bin/rm also works after sudo (where `command rm` would not)
        rm-fr = "/bin/rm";
        sudo-rm-fr = {
          regex = "^rm-fr$";
          command = "sudo";
          expansion = "/bin/rm";
        };
      };
    }
    (lib.mkIf pkgs.stdenv.isLinux {
      home.packages = [ pkgs.trash-cli ];
      systemd.user.services.trash-empty = {
        Unit.Description = "Empty trash items older than ${days} days";
        Service = {
          Type = "oneshot";
          ExecStart = "${pkgs.trash-cli}/bin/trash-empty -f ${days}";
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
  ];
}
