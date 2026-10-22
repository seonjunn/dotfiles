# VS Code on a machine with its GUI (opt-in: homeModules.vscode). VS Code itself is installed outside Nix
# (cask, apt). VS Code's Settings Sync should be off: it would be a second source.
# Each switch merges into VS Code's own files (settings-merge.py: only managed keys and entries change, so
# what the Settings UI adds stays until it is declared):
# - settings.json: config/vscode/settings.json (shared), then dotfiles.vscode.settings (the machine's own),
#   then the extension keys below.
# - keybindings.json: config/vscode/keybindings.{mac,linux}.json (cmd vs ctrl), then dotfiles.vscode.keybindings.
# Extensions are kept to a declared list:
# - settings.json gains `extensions.allowed` (only the listed ones may be installed or run; others are
#   refused and disabled) and `remote.SSH.defaultExtensions` (the `remote` list, installed on every
#   server on first connect).
# - each switch installs newly listed ones and uninstalls ones the list dropped (`code` CLI; failures only
#   warn). Extensions installed or removed by hand since the last switch are left and reported (D38).
# Hand edits of declared settings keys are kept and reported too (settings-merge.py); see *.drift.json in
# ~/.local/state/dotfiles, and `infra-update drift`.
# ui: runs on this machine only (theme, keys, remote connection). remote: runs where the files are, so
# this machine needs them too for local folders.
{ config, lib, pkgs, ... }:
let
  cfg = config.dotfiles.vscode;
  ids = map lib.toLower (cfg.ui ++ cfg.remote);
  readJSON = f: builtins.fromJSON (builtins.readFile f);
  platform = if pkgs.stdenv.isDarwin then "mac" else "linux";
  managed = pkgs.writeText "vscode-settings.json" (builtins.toJSON (
    readJSON ../../config/vscode/settings.json // cfg.settings // {
      # Todo Tree cannot find VS Code's bundled ripgrep; use the HM one (cli.nix), same path on every machine
      "todo-tree.ripgrep.ripgrep" = "${config.home.profileDirectory}/bin/rg";
      "extensions.allowed" = lib.genAttrs ids (_: true);
      "remote.SSH.defaultExtensions" = cfg.remote;
    }));
  keys = pkgs.writeText "vscode-keybindings.json" (builtins.toJSON (
    readJSON ../../config/vscode/keybindings.${platform}.json ++ cfg.keybindings));
  user = if pkgs.stdenv.isDarwin
    then "$HOME/Library/Application Support/Code/User"
    else "${config.xdg.configHome}/Code/User";
  merge = label: src: dst: state:
    ''run ${pkgs.python3}/bin/python3 -I ${./settings-merge.py} "${label}" ${src} "${user}/${dst}" "$HOME/.local/state/dotfiles/${state}" 4'';
  sync = pkgs.writeShellScript "vscode-extensions-sync" ''
    code=""
    for c in code /usr/local/bin/code /usr/bin/code "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"; do
      command -v "$c" >/dev/null 2>&1 && { code=$c; break; }
    done
    [ -n "$code" ] || { echo "vscode: no code CLI, extensions not synced"; exit 0; }
    want=" ${lib.concatStringsSep " " ids} "
    state=$HOME/.local/state/dotfiles/vscode-extensions.txt  # the list applied last time
    drift=$HOME/.local/state/dotfiles/vscode-extensions.drift.json
    prev=" $(cat "$state" 2>/dev/null || echo "$want") "
    has() { case "$2" in *" $1 "*) return 0;; esac; return 1; }
    have() { echo " $("$code" --list-extensions 2>/dev/null | tr 'A-Z' 'a-z' | tr '\n' ' ') "; }
    start=$(have); kept=""; gone=""; rm_ext=""
    # three-way (D38): remove only what the declaration dropped; one installed or removed by hand since the
    # last switch stays as it is and is reported (SETTINGS_MERGE_FORCE=1: the declaration wins)
    for x in $start; do
      has "$x" "$want" && continue
      if has "$x" "$prev" || [ "''${SETTINGS_MERGE_FORCE:-}" = 1 ]; then rm_ext="$rm_ext $x"; else kept="$kept $x"; fi
    done
    # two passes, re-reading the list each step: uninstalling an extension pack also uninstalls its
    # members (some of them wanted), and an extension others depend on only goes after them
    for pass in 1 2; do
      h=$(have)
      for x in $rm_ext; do has "$x" "$h" && "$code" --uninstall-extension "$x" >/dev/null 2>&1 && echo "vscode: removed $x"; done
      h=$(have)
      for x in $want; do
        has "$x" "$h" && continue
        if has "$x" "$start" || ! has "$x" "$prev" || [ "''${SETTINGS_MERGE_FORCE:-}" = 1 ]; then
          "$code" --install-extension "$x" >/dev/null 2>&1 && echo "vscode: installed $x" || echo "vscode: could not install $x"
        elif [ "$pass" = 1 ]; then gone="$gone $x"; fi
      done
    done
    mkdir -p "$(dirname "$state")"; echo "$want" > "$state"
    for x in $kept; do echo "vscode: kept $x, installed here by hand (not in the list)" >&2; done
    for x in $gone; do echo "vscode: did not reinstall $x, removed here by hand" >&2; done
    if [ -n "$kept$gone" ]; then
      printf '{"installed_by_hand": "%s", "removed_by_hand": "%s"}\n' "''${kept# }" "''${gone# }" > "$drift"
    else rm -f "$drift"; fi
  '';
in
{
  options.dotfiles.vscode = {
    ui = lib.mkOption { type = lib.types.listOf lib.types.str; default = [ ]; description = "Extensions that run on this machine only."; };
    remote = lib.mkOption { type = lib.types.listOf lib.types.str; default = [ ]; description = "Extensions that run where the files are (also installed on servers)."; };
    settings = lib.mkOption { type = lib.types.attrs; default = { }; description = "settings.json keys of this machine (win over the shared ones)."; };
    keybindings = lib.mkOption { type = lib.types.listOf lib.types.attrs; default = [ ]; description = "keybindings.json entries of this machine, after the platform's."; };
  };

  config.home.activation.vscode = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # first run of the extension state: the list applied last time is the extensions.allowed of the last
    # merged settings, read before this switch merges the new ones
    st=$HOME/.local/state/dotfiles
    if [ ! -f "$st/vscode-extensions.txt" ] && [ -f "$st/vscode-settings.json" ] && [ -z "''${DRY_RUN:-}" ]; then
      ${pkgs.python3}/bin/python3 -I -c 'import json,sys; print(" ".join(json.load(open(sys.argv[1])).get("extensions.allowed", {})))' \
        "$st/vscode-settings.json" > "$st/vscode-extensions.txt"
    fi
    ${merge "vscode settings" managed "settings.json" "vscode-settings.json"}
    ${merge "vscode keybindings" keys "keybindings.json" "vscode-keybindings.json"}
    if [ -z "''${DRY_RUN:-}" ]; then ${sync}; fi
  '';
}
