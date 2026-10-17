# i3 desktop on Linux (opt-in: homeModules.desktop). Links the hand-written configs and desktop scripts in
# config/desktop. Programs come from apt (i3, rofi, dunst, fcitx5 ...) or their own installers for now (B14).
# Not linked, because something writes them at runtime: rofi/theme.rasi and kitty/current-theme.conf
# (links theme-switcher swaps), GTK settings.ini, and app state (fcitx5, copyq, nitrogen).
# fcitx5's settings are seeded from config/desktop-seed when missing (a new machine), then fcitx5 owns them.
# Programs: i3, rofi, dunst, i3lock, fcitx5 ... from apt (session, PAM, input modules, theme integration);
# picom and kitty from their own builds (OpenGL with the NVIDIA driver); the rest below from Nix.
{ config, lib, pkgs, ... }:
let
  src = ../../config/desktop;
  # every file under config/desktop/<app>/ becomes ~/.config/<app>/..., one link per file so the
  # directories stay real (apps and theme-switcher add their own files next to them)
  configFiles = lib.filter (p: !(lib.hasPrefix "bin/" p) && !(lib.elem p [ "Xmodmap" "xprofile" ]))
    (map (p: lib.removePrefix "${toString src}/" (toString p)) (lib.filesystem.listFilesRecursive src));
  live = config.dotfiles.desktop.liveFrom;
  # pinned copy in the Nix store (default), or a link straight into a dotfiles checkout for live editing
  srcOf = p: if live == null then src + "/${p}" else config.lib.file.mkOutOfStoreSymlink "${live}/config/desktop/${p}";
in
{
  options.dotfiles.desktop.liveFrom = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    example = "/home/me/.dotfiles";
    description = ''
      A dotfiles checkout to link the desktop configs and scripts from, so they can be edited in place
      (save, then reload i3) instead of going through commit, push and switch. Null: pinned copies.
      Edits made this way live in that checkout until committed there.
    '';
  };

  config.home.packages = [
    pkgs.i3status-rust # bar content (i3 config: status_command ~/.nix-profile/bin/i3status-rs)
    pkgs.flashfocus    # flash the focused window
  ];

  # first-time copies of settings that the app rewrites itself
  config.home.activation.seedDesktopSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    seed() { [ -e "$2" ] || { run mkdir -p "$(dirname "$2")"; run install -m 0644 "$1" "$2"; }; }
    for f in config profile conf/hangul.conf conf/notifications.conf; do
      seed ${../../config/desktop-seed/fcitx5}/$f "$HOME/.config/fcitx5/$f"
    done
  '';

  config.xdg.configFile = lib.listToAttrs (map (p: lib.nameValuePair p { source = srcOf p; }) configFiles);

  config.home.file = {
    ".Xmodmap".source = srcOf "Xmodmap";
    ".xprofile".source = srcOf "xprofile"; # input method environment (fcitx5) for the X session
  };

  # user services of the desktop (were hand-written units on alice until 2026-10-18). They run the scripts by
  # their place in the profile, so they follow live edits too.
  config.systemd.user.services = {
    i3-focus-urgent = {
      Unit.Description = "i3 helper: focus browsers on urgency, keep Brave on the current workspace";
      Service = {
        ExecStart = "${config.home.profileDirectory}/bin/i3-focus-urgent";
        Restart = "always";
        RestartSec = 2;
        Environment = "DISPLAY=:0";
      };
      Install.WantedBy = [ "default.target" ];
    };
    theme-switcher = {
      Unit = { Description = "Time-based theme switcher"; After = [ "graphical-session.target" ]; };
      Service = { Type = "oneshot"; ExecStart = "${config.home.profileDirectory}/bin/theme-switcher auto"; };
    };
  };
  config.systemd.user.timers.theme-switcher = {
    Unit.Description = "Time-based theme switcher, every 3 minutes";
    Timer = { OnBootSec = "1m"; OnUnitActiveSec = "3m"; Persistent = true; };
    Install.WantedBy = [ "timers.target" ];
  };

  # desktop scripts go into the profile with the other commands (scripts.nix); live: run from the checkout
  config.dotfiles.scripts = lib.mapAttrs
    (n: _: if live == null then src + "/bin/${n}" else "${live}/config/desktop/bin/${n}")
    (builtins.readDir (src + "/bin"));
}
