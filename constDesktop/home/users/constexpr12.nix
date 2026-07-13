{ lib, config, ... }:
let
  inherit (lib)
    mkForce
  ;
in
{
  home.stateVersion = mkForce "25.11";
  programs.firefox.configPath = mkForce "${config.xdg.configHome}/mozilla/firefox";
  programs.zsh.dotDir = "${config.xdg.configHome}/zsh";
  imports = [
    ../../../users/constexpr12.nix
  ];
}
