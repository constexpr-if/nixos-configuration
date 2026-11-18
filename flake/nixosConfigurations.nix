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
        # services.status-api 옵션만 선언한다 — enable 전에는 무해하다.
        inputs.status-api.nixosModules.default
        (self + "/configuration.nix")
        hostconf
        # claude-code는 stable 브랜치에 버전 범프가 백포트되지 않아
        # 릴리스 시점 핀에 고정된다 — 이 패키지만 unstable에서 가져온다.
        # legacyPackages가 아니라 import인 이유: claude-code는 unfree라
        # 기본 config(allowUnfree=false)의 legacyPackages로는 평가가 죽는다.
        {
          nixpkgs.overlays = [
            # pkgs.nur.repos.<owner>.<pkg>
            inputs.nur.overlays.default
            (final: prev: {
              claude-code =
                (import inputs.nixpkgs-unstable {
                  inherit (prev.stdenv.hostPlatform) system;
                  config.allowUnfree = true;
                }).claude-code;
              # status-web 프론트엔드는 별도 flake(정적 파일 디렉터리)다.
              status-web-frontend = inputs.status-web.packages.${prev.stdenv.hostPlatform.system}.default;
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
}
