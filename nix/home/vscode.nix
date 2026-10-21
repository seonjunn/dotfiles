# VS Code on a machine with its GUI (opt-in: homeModules.vscode). VS Code itself is installed outside Nix
# (cask, apt); this keeps its extensions to a declared list:
# - settings.json gains `extensions.allowed` (only the listed ones may be installed or run; others are
#   refused and disabled) and `remote.SSH.defaultExtensions` (the `remote` list, installed on every
#   server on first connect). Merged each switch like Claude's settings (settings-merge.py): the rest of
#   settings.json stays the Settings UI's.
# - each switch installs the missing ones and uninstalls the rest locally (`code` CLI; failures only warn).
# ui: runs on this machine only (theme, keys, remote connection). remote: runs where the files are, so
# this machine needs them too for local folders.
{ config, lib, pkgs, ... }:
let
  cfg = config.dotfiles.vscode;
  ids = map lib.toLower (cfg.ui ++ cfg.remote);
  managed = pkgs.writeText "vscode-settings.json" (builtins.toJSON {
    "extensions.allowed" = lib.genAttrs ids (_: true);
    "remote.SSH.defaultExtensions" = cfg.remote;
  });
  settings = if pkgs.stdenv.isDarwin
    then "$HOME/Library/Application Support/Code/User/settings.json"
    else "${config.xdg.configHome}/Code/User/settings.json";
  sync = pkgs.writeShellScript "vscode-extensions-sync" ''
    code=""
    for c in code /usr/local/bin/code /usr/bin/code "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"; do
      command -v "$c" >/dev/null 2>&1 && { code=$c; break; }
    done
    [ -n "$code" ] || { echo "vscode: no code CLI, extensions not synced"; exit 0; }
    want=" ${lib.concatStringsSep " " ids} "
    have() { echo " $("$code" --list-extensions 2>/dev/null | tr 'A-Z' 'a-z' | tr '\n' ' ') "; }
    # two passes, re-reading the list each step: uninstalling an extension pack also uninstalls its
    # members (some of them wanted), and an extension others depend on only goes after them
    for pass in 1 2; do
      for x in $(have); do
        case "$want" in *" $x "*) ;; *) "$code" --uninstall-extension "$x" >/dev/null 2>&1 && echo "vscode: removed $x";; esac
      done
      h=$(have)
      for x in $want; do
        case "$h" in *" $x "*) ;; *) "$code" --install-extension "$x" >/dev/null 2>&1 && echo "vscode: installed $x" || echo "vscode: could not install $x";; esac
      done
    done
    h=$(have)
    for x in $h; do case "$want" in *" $x "*) ;; *) echo "vscode: still installed, not in the list: $x";; esac; done
  '';
in
{
  options.dotfiles.vscode = {
    ui = lib.mkOption { type = lib.types.listOf lib.types.str; default = [ ]; description = "Extensions that run on this machine only."; };
    remote = lib.mkOption { type = lib.types.listOf lib.types.str; default = [ ]; description = "Extensions that run where the files are (also installed on servers)."; };
  };

  config.home.activation.vscode = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${pkgs.python3}/bin/python3 -I ${./settings-merge.py} "vscode settings" ${managed} \
      "${settings}" "$HOME/.local/state/dotfiles/vscode-settings.json" 4
    if [ -z "''${DRY_RUN:-}" ]; then ${sync}; fi
  '';
}
