{ lib, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./sshd.nix
    ../../modules/hangul-console.nix
  ];
  # GUI-created Wi-Fi profiles store the PSK agent-owned in KWallet, which
  # breaks connecting at boot without a session. Removing plasma-nm (tray
  # applet + NM secret agent) forces nmcli/nmtui, which store secrets
  # system-owned by default. The plasma6 module adds plasma-nm outside the
  # excludePackages filter whenever NetworkManager is on, so an overlay is
  # the only way to keep it out.
  nixpkgs.overlays = [
    (final: prev: {
      kdePackages = prev.kdePackages.overrideScope (
        kfinal: kprev: {
          plasma-nm = final.emptyDirectory;
        }
      );
    })
  ];
  # Server duty: refuse suspend (RAM sleep) so nothing — powerdevil,
  # swayidle, a stray `systemctl suspend` — can doze the box. Hibernation
  # stays allowed as the non-destructive path into the Windows dual-boot:
  # it saves state to swap and powers off, and stage-1 auto-resumes from
  # the declared swap device on the next Linux boot.
  systemd.sleep.settings.Sleep = {
    AllowSuspend = "no";
    AllowHibernation = "yes";
    AllowSuspendThenHibernate = "no";
    AllowHybridSleep = "no";
  };
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  hardware.amdgpu.opencl.enable = true;
  networking.hostName = "constDesktop";
  networking.firewall.allowedTCPPorts = [ 25565 ];
  # Wi-Fi secrets must be system-owned (psk-flags=0) so NM can connect at
  # boot without a user session / KWallet agent. PSK lives outside the store.
  networking.networkmanager.ensureProfiles = {
    environmentFiles = [ "/etc/nixos/secrets/wifi.env" ];
    profiles =
      let
        wifiProfile = ssid: uuid: {
          connection = {
            id = ssid;
            inherit uuid;
            type = "wifi";
          };
          wifi = {
            mode = "infrastructure";
            inherit ssid;
          };
          wifi-security = {
            key-mgmt = "wpa-psk";
            psk = "$WIFI_PSK";
          };
          ipv4.method = "auto";
          ipv6.method = "auto";
        };
      in
      {
        "U+Net76E8_5G" = wifiProfile "U+Net76E8_5G" "d3694fbe-1c4a-4db0-aa10-c7841aa79c94";
        "U+Net76E8" = wifiProfile "U+Net76E8" "70ce9161-57e5-4218-a4a4-8da413f15ab5";
      };
  };
  programs.steam = {
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
  # TODO: Make module for this
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="046d", ATTR{idProduct}=="c548", ATTR{power/wakeup}="disabled"
  '';
  services.lact.enable = true;
  home-manager.users.constexpr12 = { config, ... }: {
    programs = {
      firefox.configPath = "${config.xdg.configHome}/mozilla/firefox";
      zsh.dotDir = "${config.xdg.configHome}/zsh";
    };
    home.stateVersion = "25.11";
  };
  system.stateVersion = "23.11";
}
