{
  users.users.constexpr12 = {
    isNormalUser = true;
    home = "/home/constexpr12";
    description = "constexpr-if";
    extraGroups = [ "networkmanager" "wheel" ];
  };
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "constexpr12";
}
