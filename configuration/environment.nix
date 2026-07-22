{ pkgs, ... }:
{
  sessionVariables.NIXOS_OZONE_WL = "1";
  systemPackages = with pkgs; [
    binutils
    dnsmasq
    dnsutils
    ethtool
    file
    gdb
    gettext
    gnupg
    gparted
    inetutils
    iosevka
    lsof
    net-tools
    nixfmt
    nmap
    parted
    python3
    qemu_full
    rocmPackages.rocm-smi
    rocmPackages.rocminfo
    tcpdump
    tree
    wget
    wl-clipboard-rs
  ];
}
