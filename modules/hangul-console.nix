{
  config,
  lib,
  pkgs,
  ...
}:
# Uniform login on every VT, with sway as the default session. The kernel
# console cannot render CJK and every console IME (uim-fep, fbterm) is
# abandonware, so the hangul-capable "console" is sway + a terminal +
# fcitx5 (input-method-v2/text-input-v3; same daemon and config as the
# Plasma session).
#
# sway configuration is deliberately not managed here — it reads the
# user's own ~/.config/sway/config (falling back to the stock
# /etc/sway/config). For hangul input, the config needs `exec fcitx5 -d`.
#
# greetd+tuigreet replaces SDDM as the login path: tty1 runs it at boot via
# the greetd module (which aliases itself to display-manager.service), and
# every other VT gets an identical instance through logind's autovt@ hook —
# switching to an unused VT spawns a login prompt, never a bare shell.
# Plasma stays available as a session choice in the same prompt (F3).
let
  settingsFormat = pkgs.formats.toml { };

  sessions = "${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
  tuigreetCmd = lib.concatStringsSep " " [
    "${pkgs.tuigreet}/bin/tuigreet"
    "--remember"
    "--remember-session"
    "--asterisks"
    "--sessions ${sessions}"
    "--cmd /run/current-system/sw/bin/sway"
  ];

  vtConfig =
    vt:
    settingsFormat.generate "greetd-tty${toString vt}.toml" {
      terminal.vt = vt;
      default_session = {
        command = tuigreetCmd;
        user = "greeter";
      };
    };
  vtConfigs = pkgs.linkFarm "greetd-vt-configs" (
    map (vt: {
      name = "tty${toString vt}.toml";
      path = vtConfig vt;
    }) (lib.range 2 10)
  );
  greetdVtLauncher = pkgs.writeShellScript "greetd-vt" ''
    exec ${lib.getExe config.services.greetd.package} --config ${vtConfigs}/"$1".toml
  '';
in
{
  # Both would fight greetd over autovt@/display-manager.service.
  services.kmscon.enable = lib.mkForce false;
  services.displayManager.sddm.enable = lib.mkForce false;

  # Registers the "Sway" wayland session and installs the wrapped binary.
  programs.sway.enable = true;

  # Without PAM registration swaylock cannot verify the password and the
  # session becomes unrecoverable once locked.
  security.pam.services.swaylock = { };

  # Render wlroots compositors on the CPU; a console-replacement session
  # doesn't need GLES and this keeps the GPU in its low-power state.
  # Delete to switch sway back to GPU rendering.
  environment.sessionVariables.WLR_RENDERER = "pixman";

  services.greetd = {
    enable = true;
    useTextGreeter = true;
    settings.default_session.command = tuigreetCmd;
  };

  # logind spawns autovt@ttyN.service when an unused VT is switched to;
  # point it at a per-VT greetd instance (same pattern as the kmscon
  # module). greetd only takes its VT from the config file, hence one
  # generated config per tty.
  systemd.services."greetd-vt@" = {
    after = [
      "systemd-user-sessions.service"
      "getty@%i.service"
    ];
    unitConfig.Conflicts = [ "getty@%i.service" ];
    serviceConfig = {
      ExecStart = "${greetdVtLauncher} %I";
      # Bring the login prompt back after logout.
      Restart = "on-success";
      IgnoreSIGPIPE = false;
      SendSIGHUP = true;
      TimeoutStopSec = "30s";
      KeyringMode = "shared";
      StandardInput = "tty";
      StandardOutput = "tty";
      StandardError = "journal";
      TTYPath = "/dev/%I";
      TTYReset = true;
      TTYVHangup = true;
      TTYVTDisallocate = true;
    };
    restartIfChanged = false;
    aliases = [ "autovt@.service" ];
  };
}
