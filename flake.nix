{
  description = "seonjunn dotfiles: Home Manager modules";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # software fetched from source (not a flake); `nix flake update` moves it to the latest commit
    adb-shell = { url = "github:matan-h/adb-shell"; flake = false; };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, adb-shell, ... }: {
    # Machine-agnostic modules. A machine's own config can import these and add its specifics.
    homeModules = {
      base = ./nix/home/base.nix;
      # base for an account on a shared server: login shell stays bash and hands over to fish
      server = ./nix/home/server.nix;
      # opt-in: i3 desktop configs and scripts (Linux)
      desktop = ./nix/home/desktop.nix;
      # opt-in: Android device tools (adb, fastboot, adb-shell); not part of base
      android = import ./nix/home/android.nix { inherit adb-shell; };
    };
  };
}
