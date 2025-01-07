{ config, lib, pkgs, ... }: {
  hardware.graphics.enable = true;
  hardware.nvidia.open = false;
  services.xserver.videoDrivers = ["nvidia"];
}
