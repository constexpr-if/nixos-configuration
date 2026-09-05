{
  boot.initrd.availableKernelModules = [ "nvme" ];
  boot.kernelModules = [ "kvm-amd" ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/ab18e99d-694e-41ac-bc46-5d861ed085d9";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/549B-B032";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/95a1f1eb-47e4-42fc-8963-c287d5ec56c1";
    fsType = "ext4";
  };

  fileSystems."/nix/store" = {
    device = "/dev/disk/by-uuid/a52c5cb9-dea8-47fc-b28a-a61d3c15811f";
    fsType = "ext4";
    options = [ "noatime" ];
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/343cd444-cd3e-4b30-a4b1-078c21e10377"; }
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.amd.updateMicrocode = true;
}
