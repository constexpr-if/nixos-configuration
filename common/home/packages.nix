{ pkgs, ... }: let
  joern = pkgs.callPackage (fetchGit {
    url = "git@github.com:constexpr-if/Joern-Nix-Package.git";
    rev = "0dfe23b9b66c96bdc70064825f7347ba885866d3";
  }) {};
in {
  home.packages = with pkgs; [
    burpsuite
    discord
    gdb
    ghidra
    gparted
    joern
    kitty
    maestral-gui
    (nerdfonts.override { fonts = [ "Meslo" "FiraCode" ]; })
    obs-studio
    telegram-desktop
    tetrio-desktop
    ventoy-full
    vlc
    wget
    wineWowPackages.waylandFull
    wireshark
    zed-editor
  ];
}
