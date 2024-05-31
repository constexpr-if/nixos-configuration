{ pkgs, ... }: {
  home.packages = with pkgs; [
    discord
    gparted
    maestral-gui
    #obsidian
    telegram-desktop
    ventoy-full
    wget
  ];
}
