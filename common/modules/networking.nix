{ pkgs, ... }:
{
  networking = {
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
    ];
    firewall = {
      enable = true;
      allowedTCPPorts = [ 25565 ];
    };
    wireless.enable = false;
    networkmanager.enable = true;
  };
}
