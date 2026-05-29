{ pkgs, ... }:
let
  iosevka-nerdfonts = pkgs.nerd-fonts.iosevka;
in
{
  fonts.packages = [
    iosevka-nerdfonts
    pkgs.noto-fonts-cjk-sans
    pkgs.pretendard
  ];
}
