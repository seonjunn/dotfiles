# A shared server account (lab servers): base, with the login shell left as the system bash and bash handing
# interactive logins over to Nix fish (no chsh on a machine other people use). Use instead of base.
{ lib, ... }:
{
  imports = [ ./base.nix ];
  dotfiles.bash.enable = true;

  # The keys stay on the machine I log in from; a server only has the agent each ssh session forwards, at a
  # socket that disappears with that session. Every session that brings a live agent points ~/.ssh/agent.sock
  # (ssh.nix IdentityAgent) at it, so tmux panes and later logins keep a working agent. Every ssh session runs
  # bash first (the login shell), even `ssh host cmd`, so ~/.bashrc covers them all. The target is the resolved
  # socket, never a link, so the link cannot come to point at itself.
  programs.bash.bashrcExtra = lib.mkBefore ''
    _sock=$(readlink -f -- "''${SSH_AUTH_SOCK:-}" 2>/dev/null)
    if [ -S "$_sock" ] && [ "$_sock" != "$(readlink -f -- "$HOME/.ssh/agent.sock" 2>/dev/null)" ]; then
      ln -sfn -- "$_sock" "$HOME/.ssh/agent.sock"
    fi
    unset _sock
    export SSH_AUTH_SOCK="$HOME/.ssh/agent.sock"
  '';
}
