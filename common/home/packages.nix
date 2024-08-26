{ pkgs, ... }: let
  joern = pkgs.callPackage (fetchGit {
    url = "git@github.com:constexpr-if/Joern-Nix-Package.git";
    rev = "0dfe23b9b66c96bdc70064825f7347ba885866d3";
  }) {};
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
    joern
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
