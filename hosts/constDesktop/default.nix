{ haumea, ... }:
{
  imports = [
    (haumea ./configuration)
    ./hardware-configuration.nix
  ];
  system.stateVersion = "23.11";
}
