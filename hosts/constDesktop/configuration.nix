{
  imports = [
    ./hardware-configuration.nix
    ./filesystem.nix
    ./graphics.nix
    ../../common/modules/virt.nix
    ../../common/programs/steam.nix
  ];

  networking.hostName = "constDesktop";
  system.stateVersion = "23.11";
}
