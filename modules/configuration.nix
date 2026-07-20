{ pkgs, ... }:
{
  imports = [
    ./fonts
    ./locale.nix
    ./networking.nix
    ./nix-ld.nix
    ./pipewire.nix
    ./desktop-environment/hyprland.nix
    ./desktop-environment/kde-plasma.nix
    ./substituters.nix
    ./zsh.nix
    ./syspkgs.nix
    ./waydroid.nix
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
  services.cloudflare-warp.enable = true;

  services.displayManager.autoLogin = {
    enable = true;
    user = "constexpr12";
  };
  services.xserver.excludePackages = [ pkgs.xterm ];

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;

  home-manager.backupFileExtension = "backup";

}
