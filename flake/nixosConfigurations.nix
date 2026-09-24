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
        inputs.kis-broker.nixosModules.default
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
  flake.hydraJobs = {
    constDesktop = self.nixosConfigurations.constDesktop.config.system.build.toplevel;
    constLaptopTUF = self.nixosConfigurations.constLaptopTUF.config.system.build.toplevel;
  };
}
