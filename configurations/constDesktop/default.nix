{ pkgs, ... }:
let
  rocmEnv = pkgs.symlinkJoin {
    name = "rocmEnv";
    paths = with pkgs.rocmPackages; [
      hipcc
      clr
      rocblas
      hipblas
      rocfft
      hipfft
      rocsolver
      hipsolver
      rocsparse
      hipsparse
    ];
  };
in
{
  imports = [ ./hardware-configuration.nix ];
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  hardware.amdgpu.opencl.enable = true;
  networking.hostName = "constDesktop";
  # TODO: Make module for this
  services.udev.extraRules = ''
    ACTION=="add" SUBSYSTEM=="usb" ATTR{idVendor}=="046d" ATTR{idProduct}=="c548" ATTR{power/wakeup}="disabled"
  '';
  services.lact.enable = true;
  systemd.tmpfiles.rules = [ "L+ /opt/rocm - - - - ${rocmEnv}" ];
  home-manager.users.constexpr12 = { config, ... }: {
    programs = {
      firefox.configPath = "${config.xdg.configHome}/mozilla/firefox";
      zsh.dotDir = "${config.xdg.configHome}/zsh";
    };
    home.stateVersion = "25.11";
  };
  system.stateVersion = "23.11";
}
