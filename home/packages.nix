{ pkgs, ... }: {
  home.packages = with pkgs; [
    vim
    discord
    gparted
    maestral-gui
    #obsidian
    telegram-desktop
    ventoy-full
    wget
  ];
}
