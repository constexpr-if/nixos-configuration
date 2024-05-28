{ pkgs, ... }: {
  networking = {
    nameservers = [ "1.1.1.1" "1.0.0.1" ];
    wireless.enable = false;
    networkmanager.enable = true;
  };
}