{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-26.05";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    haumea = {
      url = "github:nix-community/haumea/v0.2.2";
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }@flakes:
    let
      inherit (nixpkgs) lib;
      libpp = import ./libpp.nix flakes;
      nixosSystem =
        hostconf:
        lib.nixosSystem {
          specialArgs = { inherit libpp; };
          modules = [
            hostconf
            home-manager.nixosModules.home-manager
            (libpp.haumea-module ./configuration)
            ./property/wheel.nix
          ];
        };
    in
    {
      nixosConfigurations = {
        constDesktop = nixosSystem ./hosts/constDesktop;
        constLaptopTUF = nixosSystem ./hosts/constLaptopTUF;
      };
    };

  nixConfig = {
    substituters = [
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org"
      "https://nixcache.reflex-frp.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "ryantrinkle.com-1:JJiAKaRv9mWgpVAz8dwewnZe0AzzEAzPkagE9SP5NWI="
    ];
  };
}
