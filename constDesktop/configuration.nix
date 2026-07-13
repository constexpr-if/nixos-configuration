{
  imports = [
    ./hardware-configuration.nix
    ./filesystem.nix
    ./graphics.nix
    ./power.nix
    ../modules/virt.nix
    ../modules/steam.nix
    ../modules/bluetooth.nix
  ];

  networking.hostName = "constDesktop";
  system.stateVersion = "23.11";
}
