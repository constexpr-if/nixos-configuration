{ pkgs, ... }: {
  imports = [
    ./modules/locale.nix
    ./modules/networking.nix
    ./modules/pipewire.nix
    ./modules/desktop-environment
    ./programs/zsh.nix
  ];

  users.users.constexpr12 = {
    isNormalUser = true;
    home = "/home/constexpr12";
    extraGroups = [
      "libvirtd"
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
  };

  services.displayManager.autoLogin = {
    enable = true;
    user = "constexpr12";
  };
  services.xserver.excludePackages = [ pkgs.xterm ];

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;
}
