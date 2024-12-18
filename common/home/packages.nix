{ pkgs, ... }: let
  nerdfonts' = pkgs.nerdfonts.override { fonts = [ "Meslo" "FiraCode" ]; };
in {
  home.packages = with pkgs; [
    asciinema
    asciinema-agg
    asciinema-scenario
    burpsuite
    discord
    gdb
    ghidra
    gparted
    halloy
    iosevka
    kitty
    maestral-gui
    nerdfonts'
    obs-studio
    spotify
    telegram-desktop
    tetrio-desktop
    tcpdump
    tree
    ventoy-full
    vlc
    wget
    wineWowPackages.waylandFull
    wireshark
  ];
}
