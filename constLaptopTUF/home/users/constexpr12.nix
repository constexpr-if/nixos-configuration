{ lib, config, ... }:
let
  inherit (lib)
    mkForce
  ;
in
{
  home.stateVersion = mkForce "25.05";
  imports = [
    ../../../users/constexpr12.nix
  ];
}
