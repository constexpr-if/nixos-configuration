{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./partition.nix
    ./graphics.nix
    ../../core/system.nix
    ../../core/user.nix
    ../../modules/locale.nix
    ../../modules/networking.nix
    ../../modules/pipewire.nix
    ../../modules/xserver.nix
  ];
  
  networking.hostName = "constDesktop";
  nixpkgs.config.allowUnfree = true;
}

