{ pkgs, ... }:
let
  iosevka-custom = pkgs.iosevka.override {
    set = "Custom";
    privateBuildPlan = builtins.readFile ./iosevka.toml;
  };
  iosevka-nerdfonts = pkgs.nerd-fonts.iosevka;
in
{
  fonts.packages = [
    iosevka-custom
    iosevka-nerdfonts
  ];
}
