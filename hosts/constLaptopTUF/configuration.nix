{
  imports = [
    ./hardware-configuration.nix
    ../../common/modules/bluetooth.nix
  ];

  networking.hostName = "constLaptopTUF";
  system.stateVersion = "24.05";
}
