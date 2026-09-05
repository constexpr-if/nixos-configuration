{
  self,
  inputs,
  home-manager,
  ...
}:
let
  hmModule = inputs.home-manager.nixosModules.home-manager;
  nixosSystem =
    hostconf:
    inputs.nixpkgs.lib.nixosSystem {
      modules = [
        hmModule
        (self + "/configuration.nix")
        hostconf
      ];
    };
in
{
  flake.nixosConfigurations = {
    constDesktop = nixosSystem (self + "/configurations/constDesktop");
    constLaptopTUF = nixosSystem (self + "/configurations/constLaptopTUF");
  };
}
