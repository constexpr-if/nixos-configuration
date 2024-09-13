{
  imports = [
    ./hardware-configuration.nix
    ./graphics.nix
    ../../common/modules/bluetooth.nix
  ];

  networking.hostName = "constLaptop";
  system.stateVersion = "24.05";
}
