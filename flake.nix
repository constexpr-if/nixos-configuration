{
  description = "NixOS Configuration";

  nixConfig = {
    substituters = [
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }:
    let
      mkHost =
        system: hostname:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./common/configuration.nix
            ./hosts/${hostname}/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.constexpr12 = import ./hosts/${hostname}/home;
            }
          ];
        };
    in
    {
      nixosConfigurations.constDesktop = mkHost "x86_64-linux" "constDesktop";
      nixosConfigurations.constLaptopTUF = mkHost "x86_64-linux" "constLaptopTUF";
    };
}
