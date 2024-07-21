{ pkgs, ... }: {
  users.users.constexpr12 = {
    isNormalUser = true;
    home = "/home/constexpr12";
    description = "constexpr-if";
    extraGroups = [
      "libvirtd"
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
  };
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "constexpr12";
}
