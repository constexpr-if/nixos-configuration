{ config, lib, ... }:
{
  config = lib.mkIf config.kdepackages.sddm.enable {
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
  };
}
