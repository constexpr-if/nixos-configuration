{
  services.xserver.enable = true;
  imports = [
    ./kde-plasma.nix
  ];
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
