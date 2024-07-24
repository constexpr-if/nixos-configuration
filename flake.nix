{
  description = "NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ...}:
    let
      mkHost = system: hostname: nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/${hostname}/configuration.nix
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.constexpr12 = import ./home;
          }
        ];
      };
    in
    {
      nixosConfigurations.constDesktop = mkHost "x86_64-linux" "constDesktop";
      nixosConfigurations.constLaptop  = mkHost "x86_64-linux" "constLaptop";
    };
}
