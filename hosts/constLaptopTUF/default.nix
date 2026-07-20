{ haumea, ... }:
{
  imports = [
    (haumea ./configuration)
    ./hardware-configuration.nix
  ];
}
