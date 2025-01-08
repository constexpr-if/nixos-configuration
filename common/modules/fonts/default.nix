{ pkgs, ... }: let
  iosevka-custom = pkgs.iosevka.override {
    set = "Custom";
    privateBuildPlan = builtins.readFile ./iosevka.toml;
  };
  iosevka-nerdfonts = pkgs.nerdfonts.override { fonts = [ "Iosevka" ]; };
in {
  fonts.packages = [
    iosevka-custom
    iosevka-nerdfonts
  ];
}
