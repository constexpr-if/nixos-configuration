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
        # claude-code는 stable 브랜치에 버전 범프가 백포트되지 않아
        # 릴리스 시점 핀에 고정된다 — 이 패키지만 unstable에서 가져온다.
        # legacyPackages가 아니라 import인 이유: claude-code는 unfree라
        # 기본 config(allowUnfree=false)의 legacyPackages로는 평가가 죽는다.
        {
          nixpkgs.overlays = [
            (final: prev: {
              claude-code =
                (import inputs.nixpkgs-unstable {
                  inherit (prev.stdenv.hostPlatform) system;
                  config.allowUnfree = true;
                }).claude-code;
            })
          ];
        }
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
    webapps-test = self.checks.x86_64-linux.webapps;
  };
}
