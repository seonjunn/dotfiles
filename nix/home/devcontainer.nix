# My dev containers, for bin/devc (~/.config/devc/config.json): the Features (devcontainer/*, by exact version),
# the releases this machine's Home Manager installs (used where the docker host has no Nix to lend its profile),
# and this repo as the dotfiles that bootstrap/container.sh applies at create time.
{ config, pkgs, ... }:
let
  readJSON = f: builtins.fromJSON (builtins.readFile f);
  feature = name: "ghcr.io/seonjunn/dotfiles/${name}:${(readJSON ../../devcontainer/${name}/devcontainer-feature.json).version}";
  packages = builtins.fromTOML (builtins.readFile ../data/packages.toml);
  npmPin = name: pkg: (readJSON ../packages/${name}/package.json).dependencies.${pkg};
in
{
  xdg.configFile."devc/config.json".text = builtins.toJSON {
    personal = feature "personal";
    releases = {
      fish = config.programs.fish.package.version;
      tmux = config.programs.tmux.package.version;
      fzf = config.programs.fzf.package.version;
      zoxide = config.programs.zoxide.package.version;
      ripgrep = pkgs.ripgrep.version;
      gum = pkgs.gum.version;
      eza = pkgs.eza.version;
      uv = pkgs.uv.version;
      node = pkgs.${builtins.head packages.runtime.names}.version;
      codex = npmPin "codex" "@openai/codex";
      ccs = npmPin "ccs" "@kaitranntt/ccs";
    };
    dotfiles = {
      repository = "https://github.com/seonjunn/dotfiles";
      targetPath = "~/.dotfiles";
      installCommand = "bootstrap/container.sh";
    };
  };
}
