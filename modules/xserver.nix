{
  services.xserver.enable = true;
  services.displayManager = {
    sddm.enable = true;
    sddm.wayland.enable = true;
  };
  services.desktopManager.plasma6.enable = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
