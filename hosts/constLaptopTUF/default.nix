{ libpp, ... }: with libpp;
{
  imports = [
    (haumea-module ./configuration)
    ./hardware-configuration.nix
  ];
  system.stateVersion = "24.05";
}
