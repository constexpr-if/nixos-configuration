{ config, lib, ... }:
with lib;
let
  inherit (config.users.groups) wheel;
  configuration = {
    programs.git.enable = true;
    programs.git.settings.safe = {
      directory = "/etc/nixos";
    };
  };
in
{
  home-manager.useUserPackages = mkForce false;
  home-manager.users = genAttrs wheel.members (const configuration);
}
