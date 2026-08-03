{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-26.05";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }@flakes:
    let
      inherit (nixpkgs) lib;
      inherit (home-manager) nixosModules;
      nixosSystem =
        hostconf:
        lib.nixosSystem {
          modules = [
            hostconf
            nixosModules.home-manager
            ./configuration.nix
            ./modules/wheel.nix
          ];
        };
    in
    {
      nixosConfigurations = {
        constDesktop = nixosSystem ./configurations/constDesktop;
        constLaptopTUF = nixosSystem ./configurations/constLaptopTUF;
      };
    };

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
}
