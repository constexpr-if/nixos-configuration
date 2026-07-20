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
    { nixpkgs, ... }@flakes:
    let
      inherit (nixpkgs.lib) nixosSystem;
      inherit (flakes.home-manager.nixosModules) home-manager;
      haumea =
        src:
        { pkgs, ... }@args:
        flakes.haumea.lib.load {
          inherit src;
          inputs = args // {
            inherit haumea;
          };
        };
    in
    {
      nixosConfigurations.constDesktop = nixosSystem {
        specialArgs = { inherit haumea; };
        modules = [
          home-manager
          (haumea ./configuration)
          ./hosts/constDesktop
          { system.stateVersion = "23.11"; }
        ];

      };
      nixosConfigurations.constLaptopTUF = nixosSystem {
        specialArgs = { inherit haumea; };
        modules = [
          home-manager
          (haumea ./configuration)
          ./hosts/constLaptopTUF
          { system.stateVersion = "24.05"; }
        ];
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
