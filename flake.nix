{
  description = "NixOS Configuration";

  nixConfig = {
    substituters = [
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org"
      "https://ihaskell.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "ihaskell.cachix.org-1:WoIvex/Ft/++sjYW3ntqPUL3jDGXIKDpX60pC8d5VLM="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { nixpkgs, home-manager, ... }:
    let
      mkHost =
        hostname:
        nixpkgs.lib.nixosSystem {
          modules = [
            ./modules/configuration.nix
            ./${hostname}/configuration.nix
            home-manager.nixosModules.home-manager
            ./${hostname}/home
          ];
        };
    in
    {
      nixosConfigurations.constDesktop = mkHost "constDesktop";
      nixosConfigurations.constLaptopTUF = mkHost "constLaptopTUF";
    };
}
