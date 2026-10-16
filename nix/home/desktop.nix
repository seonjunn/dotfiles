# i3 desktop on Linux (opt-in: homeModules.desktop). Links the hand-written configs and desktop scripts in
# config/desktop. Programs come from apt (i3, rofi, dunst, fcitx5 ...) or their own installers for now (B14).
# Not linked, because something writes them at runtime: rofi/theme.rasi and kitty/current-theme.conf
# (links theme-switcher swaps), GTK settings.ini, and app state (fcitx5, copyq, nitrogen).
# fcitx5's settings are seeded from config/desktop-seed when missing (a new machine), then fcitx5 owns them.
# Programs: i3, rofi, dunst, i3lock, fcitx5 ... from apt (session, PAM, input modules, theme integration);
# picom and kitty from their own builds (OpenGL with the NVIDIA driver); the rest below from Nix.
{ lib, pkgs, ... }:
let
  src = ../../config/desktop;
  # every file under config/desktop/<app>/ becomes ~/.config/<app>/..., one link per file so the
  # directories stay real (apps and theme-switcher add their own files next to them)
  configFiles = lib.filter (p: !(lib.hasPrefix "bin/" p) && !(lib.elem p [ "Xmodmap" "xprofile" ]))
    (map (p: lib.removePrefix "${toString src}/" (toString p)) (lib.filesystem.listFilesRecursive src));
in
{
  home.packages = [
    pkgs.i3status-rust # bar content (i3 config: status_command ~/.nix-profile/bin/i3status-rs)
    pkgs.flashfocus    # flash the focused window
  ];

  # first-time copies of settings that the app rewrites itself
  home.activation.seedDesktopSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    seed() { [ -e "$2" ] || { run mkdir -p "$(dirname "$2")"; run install -m 0644 "$1" "$2"; }; }
    for f in config profile conf/hangul.conf conf/notifications.conf; do
      seed ${../../config/desktop-seed/fcitx5}/$f "$HOME/.config/fcitx5/$f"
    done
  '';

  xdg.configFile = lib.listToAttrs (map (p: lib.nameValuePair p { source = src + "/${p}"; }) configFiles);

  home.file = {
    ".Xmodmap".source = src + "/Xmodmap";
    ".xprofile".source = src + "/xprofile"; # input method environment (fcitx5) for the X session
  }
  // lib.mapAttrs' (n: _: lib.nameValuePair ".local/bin/${n}" { source = src + "/bin/${n}"; })
    (builtins.readDir (src + "/bin"));
}
