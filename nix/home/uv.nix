# Global Python command-line tools through `uv tool` (decision D39: Python only through uv; projects use their own
# uv environments, nothing goes into a system Python or `pip install --user`). uv itself comes from cli.nix.
# Each switch keeps the installed tools to dotfiles.uv.tools, three-way (D38): a tool the list dropped since the
# last switch is uninstalled, a listed one is installed, and one installed or removed by hand is left as it is and
# reported (~/.local/state/dotfiles/uv-tools.drift.json). SETTINGS_MERGE_FORCE=1: the list wins.
# Python versions are not listed: uv fetches the one a project asks for.
{ config, lib, pkgs, ... }:
let
  tools = config.dotfiles.uv.tools;
  locked = config.dotfiles.uv.lockedTools;
  sync = pkgs.writeShellScript "uv-tools-sync" ''
    uv=${pkgs.uv}/bin/uv
    st=$HOME/.local/state/dotfiles; mkdir -p "$st"
    state=$st/uv-tools.txt; drift=$st/uv-tools.drift.json
    want=" ${lib.concatStringsSep " " tools} "
    first=1; prev=" "
    [ -f "$state" ] && { first=0; prev=" $(cat "$state") "; }
    has() { case "$2" in *" $1 "*) return 0;; esac; return 1; }
    force() { [ "''${SETTINGS_MERGE_FORCE:-}" = 1 ]; }
    # only coreutils, grep and sed are on the activation PATH (no awk)
    have=" $("$uv" tool list 2>/dev/null | grep -E '^[A-Za-z0-9_.-]+ v[0-9]' | cut -d' ' -f1 | tr '\n' ' ') "
    kept=""; gone=""
    for t in $have; do
      has "$t" "$want" && continue
      has "$t" " ${lib.concatStringsSep " " (builtins.attrNames locked)} " && continue
      if has "$t" "$prev" || force; then "$uv" tool uninstall "$t" >/dev/null 2>&1 && echo "uv: uninstalled $t"
      else kept="$kept $t"; fi
    done
    for t in $want; do
      has "$t" "$have" && continue
      if [ $first = 1 ] || ! has "$t" "$prev" || force; then
        "$uv" tool install "$t" >/dev/null 2>&1 && echo "uv: installed $t" || echo "uv: could not install $t"
      else gone="$gone $t"; fi
    done
    echo "$want" > "$state"
    for t in $kept; do echo "uv: kept $t, installed here by hand (not in dotfiles.uv.tools)" >&2; done
    for t in $gone; do echo "uv: did not reinstall $t, removed here by hand" >&2; done
    if [ -n "$kept$gone" ]; then
      printf '{"installed_by_hand": "%s", "removed_by_hand": "%s"}\n' "''${kept# }" "''${gone# }" > "$drift"
    else rm -f "$drift"; fi
  '';
in
{
  options.dotfiles.uv.tools = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    description = "Python CLI tools installed with `uv tool install` (package names).";
  };

  options.dotfiles.uv.lockedTools = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule {
      options = {
        version = lib.mkOption { type = lib.types.str; };
        requirements = lib.mkOption { type = lib.types.path; };
      };
    });
    default = { };
    description = "uv tools installed into versioned environments from pinned requirements.";
  };

  config.home.activation.uvTools = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -z "''${DRY_RUN:-}" ]; then ${sync}; fi
  '';

  config.home.activation.uvLockedTools = lib.hm.dag.entryAfter [ "uvTools" ] ''
    if [ -z "''${DRY_RUN:-}" ]; then
      ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: spec: ''
        run ${pkgs.python3}/bin/python3 -I ${./uv-locked.py} ${pkgs.uv}/bin/uv \
          ${lib.escapeShellArg name} ${lib.escapeShellArg spec.version} ${spec.requirements}
      '') locked)}
    fi
  '';
}
