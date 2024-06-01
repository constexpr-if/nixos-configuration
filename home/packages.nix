{ pkgs, ... }: {
  home.packages = with pkgs; [
    discord
    gparted
    maestral-gui
    obs-studio
    #obsidian
    telegram-desktop
    ventoy-full
    vlc
    wget
    wineWowPackages.waylandFull
  ];
}
