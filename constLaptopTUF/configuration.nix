{
  imports = [
    ./hardware-configuration.nix
    ./keymap.nix
    ../modules/bluetooth.nix
  ];

  networking.hostName = "constLaptopTUF";
  system.stateVersion = "24.05";
}
