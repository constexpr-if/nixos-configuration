{
  imports = [
    ./hardware-configuration.nix
    ../../common/modules/bluetooth.nix
  ];

  networking.hostName = "constLaptop";
  system.stateVersion = "23.11";
}
