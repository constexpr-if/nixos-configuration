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
  programs.ssh.knownHosts."constdesktop".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICxHF3hLZP1qYgBEvardRDS0xtLgNwXX1Dmqd1/YKRYI";
  services.xserver.xkb.options = "korean:ralt_hangul";
  system.stateVersion = "24.05";
}
