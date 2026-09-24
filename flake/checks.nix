{ self, inputs, ... }:
let
  pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
in
{
  # nix flake check / nix build .#checks.x86_64-linux.<name> 로 로컬 실행,
  # Hydra에는 hydraJobs로 노출한다 (nixosConfigurations.nix).
  flake.checks.x86_64-linux = {
    webapps = pkgs.testers.runNixOSTest (self + "/tests/webapps.nix");
  };
}
