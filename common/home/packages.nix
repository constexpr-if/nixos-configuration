{ pkgs, ... }:
{
  home.packages = with pkgs; [
    asciinema
    asciinema-agg
    asciinema-scenario
    binutils
    burpsuite
    discord
    dropbox
    font-manager
    gdb
    ghidra
    gparted
    halloy
    ida-free
    iosevka
    kitty
    lua-language-server
    nixd
    obs-studio
    ripgrep
    rofi
    spotify
    telegram-desktop
    tetrio-desktop
    tcpdump
    tree
    tree-sitter
    ventoy-full
    vlc
    wget
    wineWowPackages.waylandFull
    wireshark
    wl-clipboard-rs
  ];
}
