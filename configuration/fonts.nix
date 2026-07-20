{ pkgs, ... }: {
  packages = with pkgs; [
    nerd-fonts.iosevka
    noto-fonts-cjk-sans
    pretendard
  ];
}
