{ pkgs, ... }: {
  xserver = {
    enable = true;
    excludePackages = [ pkgs.xterm ];
  };
  desktopManager.plasma6.enable = true;
  displayManager.defaultSession = "plasma";
  displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
  cloudflare-warp.enable = true;
}
