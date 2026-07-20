{ pkgs, ... }: {
  users = {
    constexpr12 = {
      isNormalUser = true;
      home = "/home/constexpr12";
      extraGroups = [
        "libvirtd"
        "networkmanager"
        "wheel"
      ];
      shell = pkgs.zsh;
    };
  };
}
