{ pkgs, ... }:
{
  services.openssh = {
    enable = true;
    openFirewall = true;
    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
    authorizedKeysInHomedir = false;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = [
        "constexpr12"
        "nixremote"
      ];
      MaxAuthTries = 3;
      PerSourcePenalties = "crash:3600s authfail:3600s max:86400s";
    };
  };
  users.users."constexpr12".openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOFcsVWuCOiqsbdNV8ED17/ICy/2n21tTWnHbH/HZg2R"
  ];

  # Dedicated account for nix builds offloaded from the laptop. nix
  # trusted-users is effectively root-equivalent toward the nix daemon, so
  # it is granted only to this account, whose sole key lives in the
  # laptop's /root/.ssh — never to the interactive user.
  users.users.nixremote = {
    isSystemUser = true;
    group = "nixremote";
    home = "/var/lib/nixremote";
    createHome = true;
    shell = pkgs.bashInteractive;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJTEF8N2ymmMwuDgB8Pcl3CL2aDnF0keZMoZ9Ph8TDsm nix-builder@constLaptopTUF"
    ];
  };
  users.groups.nixremote = { };
  nix.settings.trusted-users = [ "nixremote" ];
}
