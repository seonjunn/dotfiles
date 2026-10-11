{
  description = "seonjunn dotfiles: Home Manager modules";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }: {
    # Machine-agnostic modules. Machine-specific configs import these (see the private infra repo).
    homeModules = {
      base = ./nix/home/base.nix;
      cli = ./nix/home/cli.nix;
    };
  };
}
