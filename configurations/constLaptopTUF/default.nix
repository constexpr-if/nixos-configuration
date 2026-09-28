{
  imports = [ ./hardware-configuration.nix ];
  home-manager.users.constexpr12 = {
    home.stateVersion = "25.05";
  };
  networking.hostName = "constLaptopTUF";
  # Offload builds to the desktop over the tailnet. The connecting identity
  # is the laptop's nix-daemon (root), keyed by /root/.ssh/id_ed25519 and
  # accepted only by the desktop's key-scoped `nixremote` account.
  nix.distributedBuilds = true;
  nix.settings.builders-use-substitutes = true;
  nix.buildMachines = [
    {
      hostName = "constdesktop";
      system = "x86_64-linux";
      protocol = "ssh-ng";
      sshUser = "nixremote";
      sshKey = "/root/.ssh/id_ed25519";
      maxJobs = 6;
      speedFactor = 2;
      supportedFeatures = [
        "big-parallel"
        "kvm"
        "nixos-test"
      ];
    }
  ];
  # Pull what Hydra already built on the desktop (unfree apps, host-local
  # config) straight from its harmonia cache instead of routing each
  # missing path through the remote builder. priority=50 keeps it behind
  # cache.nixos.org (40), so ordinary nixpkgs lookups don't pay the extra
  # hop. The desktop may be hibernated: a short connect-timeout keeps the
  # dead substituter from stalling a switch, and fallback lets nix build
  # instead of aborting when a listed cache can't serve a path.
  nix.settings = {
    substituters = [ "http://constdesktop:5000?priority=50" ];
    trusted-public-keys = [ "constdesktop-1:X7Gocs2tpe9R/4Xnxqp3+M43u0B/Omkm47+kthvt0WM=" ];
    connect-timeout = 5;
    fallback = true;
  };
  programs.ssh.knownHosts."constdesktop".publicKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICxHF3hLZP1qYgBEvardRDS0xtLgNwXX1Dmqd1/YKRYI";
  services.xserver.xkb.options = "korean:ralt_hangul";
  system.stateVersion = "24.05";
}
