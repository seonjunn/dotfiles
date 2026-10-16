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
    # Machine-agnostic modules. A machine's own config can import these and add its specifics.
    homeModules = {
      base = ./nix/home/base.nix;
    };
  };
}
