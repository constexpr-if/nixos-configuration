{ haumea, ... }:
{
  imports = [
    (haumea ./configuration)
    ./hardware-configuration.nix
  ];
  system.stateVersion = "24.05";
}
