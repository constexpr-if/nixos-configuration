{
  imports = [ ./hardware-configuration.nix ];
  home-manager.users.constexpr12 = {
    home.stateVersion = "25.05";
  };
  networking.hostName = "constLaptopTUF";
  services.xserver.xkb.options = "korean:ralt_hangul";
  system.stateVersion = "24.05";
}
