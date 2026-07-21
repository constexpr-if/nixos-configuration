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
      haumea =
        src:
        { pkgs, ... }@args:
        flakes.haumea.lib.load {
          inherit src;
          inputs = args // {
            inherit haumea;
          };t
        };
      nixosSystem =
        modules:
        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit haumea; };
          inherit modules;
        };
      common = [
        home-manager.nixosModules.home-manager
        (haumea ./configuration)
      ];
    in
    {
      nixosConfigurations.constDesktop = nixosSystem (common ++ [ ./hosts/constDesktop ]);
      nixosConfigurations.constLaptopTUF = nixosSystem (common ++ [ ./hosts/constLaptopTUF ]);
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
