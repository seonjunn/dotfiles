# Instruction files and skills for coding agents (Claude Code, Codex), and the IPython profile.
# Files are linked. ~/.claude/settings.json is Claude's own (it writes /model, "always allow", ...),
# so each switch merges config/claude/settings.json into it instead (claude-settings-merge.py).
# Session state stays the tools' own.
# ~/.claude/{skills,commands,agents} stay real directories with one link per entry, so local
# additions (e.g. a synced skill) live next to these.
{ lib, pkgs, ... }:
let
  cfg = ../../config;
  linkEach = dst: dir:
    lib.optionalAttrs (builtins.pathExists dir)
      (lib.mapAttrs' (n: _: lib.nameValuePair "${dst}/${n}" { source = dir + "/${n}"; }) (lib.filterAttrs (n: _: !lib.hasPrefix "." n) (builtins.readDir dir))); # skip .gitkeep
in
{
  home.file = {
    ".claude/CLAUDE.md".source = cfg + "/claude/CLAUDE.md";
    ".claude/statusline.py".source = cfg + "/claude/statusline.py";
    ".codex/AGENTS.md".source = cfg + "/agents/AGENTS.md";
    ".agents/skills".source = cfg + "/agents/skills";
    ".ipython/profile_default/ipython_config.py".source = cfg + "/ipython/profile_default/ipython_config.py";
  }
  // linkEach ".claude/skills" (cfg + "/agents/skills")
  // linkEach ".claude/commands" (cfg + "/claude/commands")
  // linkEach ".claude/agents" (cfg + "/claude/agents");

  home.activation.claudeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${pkgs.python3}/bin/python3 -I ${./claude-settings-merge.py} ${cfg + "/claude/settings.json"}
  '';
}
