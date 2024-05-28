{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../core/system.nix
    ../../core/user.nix
    ../../modules/locale.nix
    ../../modules/networking.nix
    ../../modules/xserver.nix
  ];
  
  networking.hostName = "constLaptop";
  nixpkgs.config.allowUnfree = true;
}
