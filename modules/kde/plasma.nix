{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.kdepackages.plasma.enable {
    services.desktopManager.plasma6.enable = true;
    services.displayManager.defaultSession = "plasma";
    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      aurorae
      plasma-browser-integration
      plasma-workspace-wallpapers
      konsole
      kwin-x11
      ark
      elisa
      gwenview
      okular
      kate
      ktexteditor
      khelpcenter
      dolphin
      baloo-widgets
      dolphin-plugins
      spectacle
      ffmpegthumbs
      krdp
      plasma-keyboard
      qtvirtualkeyboard
      qrca
      qtsensors
      discover
    ];
    programs.kde-pim.enable = false;
  };
}
