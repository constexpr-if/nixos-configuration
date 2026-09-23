{ config, lib, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./sshd.nix
    ./trading.nix
    ../../modules/greetd-sway.nix
    ../../modules/status-web.nix
  ];
  # Plasma wires drkonqi-coredump-processor@ into every systemd-coredump@
  # run (plasma6.nix does this unconditionally, bypassing excludePackages).
  # Without a Plasma session to collect the results the processors linger
  # at ~40MB each. Dumps themselves are still recorded by systemd-coredump.
  systemd.services."drkonqi-coredump-processor@".wantedBy = lib.mkForce [ ];
  # Android container: off until actually needed (shared config enables it).
  virtualisation.waydroid.enable = lib.mkForce false;
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
  # Idle-power trim, measured 2026-09-06 with the status-web power line:
  # powertop auto-tune (USB autosuspend, audio power save — wall-side only)
  # and ASPM powersupersave (package 16.3W → ~15.8W; PCIe controller sits
  # on the IO die). This is the software floor for AM4 + dGPU; further
  # cuts live in BIOS (ErP, RAM/fclk clock) or PSU efficiency.
  powerManagement.powertop.enable = true;
  # dGPU runtime PM (BACO) never engages while fbcon keeps repainting the
  # blinking cursor: each repaint refreshes amdgpu's 5s autosuspend timer,
  # so the card sits in D0 forever even with no display attached
  # (suspended_time stayed 0ms since boot). Stop the blink outright — the
  # tmpfiles write applies on activation, no reboot — and blank the
  # console after 60s idle as the general backstop.
  # The LG UltraGear drops DP HPD in deep standby, so a boot with the
  # monitor asleep leaves DP-1 "disconnected" and fbcon with no CRTC
  # ("Cannot find any crtc or sizes") — and once the card enters BACO it
  # never re-probes, so keypresses unblank into nothing. Forcing DP-1
  # enabled with a fixed mode gives fbcon a CRTC regardless of detection;
  # runtime PM is unaffected because suspend keys off active CRTCs, not
  # connector status: consoleblank still disables the pipe and BACO
  # engages as before. 60Hz on purpose — console output, always in spec.
  boot.kernelParams = [
    "pcie_aspm.policy=powersupersave"
    "consoleblank=60"
    "video=DP-1:1920x1080@60e"
  ];
  systemd.tmpfiles.rules = [ "w /sys/class/graphics/fbcon/cursor_blink - - - - 0" ];
  # SMU telemetry: `sudo ryzen-monitor-ng` shows package-C6/fabric
  # residency the OS cannot see — for verifying the BIOS "DF Cstates"
  # lever before/after.
  boot.extraModulePackages = [ config.boot.kernelPackages.ryzen-smu ];
  boot.kernelModules = [ "ryzen_smu" ];
  environment.systemPackages = [ pkgs.ryzen-monitor-ng ]; # root-only SMU reader
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
  # SlimBlade Pro (047d:80d7): USB autosuspend adds a wake-up stutter on the
  # first movement, so pin it awake. The udev rule covers replug; the boot
  # path needs the oneshot below because powertop --auto-tune runs at
  # multi-user.target — after udev has processed the device — and flips
  # every USB device back to "auto".
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="046d", ATTR{idProduct}=="c548", ATTR{power/wakeup}="disabled"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="047d", ATTR{idProduct}=="80d7", ATTR{power/control}="on"
  '';
  systemd.services.trackball-no-autosuspend = {
    description = "Keep SlimBlade Pro out of USB autosuspend (powertop overrides udev at boot)";
    after = [ "powertop.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      for d in /sys/bus/usb/devices/*/; do
        if [ "$(cat "$d/idVendor" 2>/dev/null)" = "047d" ] && [ "$(cat "$d/idProduct" 2>/dev/null)" = "80d7" ]; then
          echo on > "$d/power/control"
        fi
      done
    '';
  };
  home-manager.users.constexpr12 = { config, pkgs, ... }: {
    programs = {
      firefox.configPath = "${config.xdg.configHome}/mozilla/firefox";
      zsh.dotDir = "${config.xdg.configHome}/zsh";
    };
    # Remote Control host: lets claude.ai/code and the mobile app open
    # sessions on this box (new sessions spawn in $HOME). Linger is on for
    # this user, so it comes up at boot with no login.
    systemd.user.services.claude-rc = {
      Unit = {
        Description = "Claude Code Remote Control (claude.ai/code)";
        After = [ "network-online.target" ];
      };
      Service = {
        WorkingDirectory = "%h";
        ExecStart = "${pkgs.claude-code}/bin/claude remote-control --name constDesktop";
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install.WantedBy = [ "default.target" ];
    };
    home.stateVersion = "25.11";
  };
  system.stateVersion = "23.11";
}
