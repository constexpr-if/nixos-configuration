{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./filesystem.nix
    ./graphics.nix
    ../../core/system.nix
    ../../core/user.nix
    ../../modules/locale.nix
    ../../modules/networking.nix
    ../../modules/pipewire.nix
    ../../modules/virt.nix
    ../../modules/xserver.nix
    ../../programs/steam.nix
  ];
  
  networking.hostName = "constDesktop";
  nixpkgs.config.allowUnfree = true;
}

