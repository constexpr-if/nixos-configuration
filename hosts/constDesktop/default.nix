{ libpp, ... }: with libpp;
{
  imports = [
    (haumea-module ./configuration)
    ./hardware-configuration.nix
  ];
  system.stateVersion = "23.11";
}
