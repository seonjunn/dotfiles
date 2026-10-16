# i3 desktop on Linux (opt-in: homeModules.desktop). Links the hand-written configs and desktop scripts in
# config/desktop. Programs come from apt (i3, rofi, dunst, fcitx5 ...) or their own installers for now (B14).
# Not linked, because something writes them at runtime: rofi/theme.rasi and kitty/current-theme.conf
# (theme-switcher swaps them), GTK settings.ini, and app state (fcitx5, copyq, nitrogen).
{ lib, ... }:
let
  src = ../../config/desktop;
  # every file under config/desktop/<app>/ becomes ~/.config/<app>/..., one link per file so the
  # directories stay real (apps and theme-switcher add their own files next to them)
  configFiles = lib.filter (p: !(lib.hasPrefix "bin/" p) && !(lib.elem p [ "Xmodmap" "xprofile" ]))
    (map (p: lib.removePrefix "${toString src}/" (toString p)) (lib.filesystem.listFilesRecursive src));
in
{
  xdg.configFile = lib.listToAttrs (map (p: lib.nameValuePair p { source = src + "/${p}"; }) configFiles);

  home.file = {
    ".Xmodmap".source = src + "/Xmodmap";
    ".xprofile".source = src + "/xprofile"; # input method environment (fcitx5) for the X session
  }
  // lib.mapAttrs' (n: _: lib.nameValuePair ".local/bin/${n}" { source = src + "/bin/${n}"; })
    (builtins.readDir (src + "/bin"));
}
