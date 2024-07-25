{
  services.xserver.enable = true;
  imports = [
    ./hyprland.nix
    ./kde-plasma.nix
  ];
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
