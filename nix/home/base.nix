# Settings every machine gets: shell, CLI tools, git, ssh defaults, tmux/vim, node, agent files.
# A machine's own config imports this and adds its values (identity, ssh hosts, extra packages)
# through the same Home Manager options; they merge.
{ ... }:
{
  imports = [
    ./fish.nix
    ./cli.nix
    ./git.nix
    ./ssh.nix
    ./terminal.nix
    ./node.nix
    ./agents.nix
    ./trash.nix
    ./bash.nix
    ./systemd.nix
    ./scripts.nix
    ./uv.nix
  ];

  programs.home-manager.enable = true;
}
