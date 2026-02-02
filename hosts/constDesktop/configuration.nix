{
  imports = [
    ./hardware-configuration.nix
    ./filesystem.nix
    ./graphics.nix
    ./power.nix
    ../../common/modules/virt.nix
    ../../common/programs/steam.nix
  ];

  networking.hostName = "constDesktop";
  system.stateVersion = "23.11";
}
