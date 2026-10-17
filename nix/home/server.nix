# A shared server account (lab servers): base, with the login shell left as the system bash and bash handing
# interactive logins over to Nix fish (no chsh on a machine other people use). Use instead of base.
{ ... }:
{
  imports = [ ./base.nix ];
  dotfiles.bash.enable = true;
}
