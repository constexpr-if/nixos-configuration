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
    kitty
    maestral-gui
    nerdfonts'
    obs-studio
    telegram-desktop
    tetrio-desktop
    tor-browser
    ventoy-full
    vlc
    wget
    wineWowPackages.waylandFull
    wireshark
    zed-editor
  ];
}
