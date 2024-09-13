{
  imports = [
    ./hardware-configuration.nix
    ./graphics.nix
    ../../common/modules/bluetooth.nix
  ];

  networking.hostName = "constLaptopTUF";
  system.stateVersion = "24.05";
}
