let
  host-configuration = {
    imports = [ hardware-configuration ];
    home-manager.users.constexpr12 = {
      home.stateVersion = "25.05";
    };
    networking.hostName = "constLaptopTUF";
    services.xserver.xkb.options = "korean:ralt_hangul";
    system.stateVersion = "24.05";
  };

  hardware-configuration =
    {
      config,
      lib,
      pkgs,
      modulesPath,
      ...
    }:

    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
      ];

      boot.initrd.availableKernelModules = [
        "nvme"
        "xhci_pci"
        "thunderbolt"
        "usb_storage"
        "sd_mod"
        "rtsx_pci_sdmmc"
      ];
      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ "kvm-amd" ];
      boot.extraModulePackages = [ ];

      fileSystems."/" = {
        device = "/dev/disk/by-uuid/697f6cd7-4f31-429b-b90d-03a514f556f9";
        fsType = "ext4";
      };

      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/E2D6-E369";
        fsType = "vfat";
        options = [
          "fmask=0077"
          "dmask=0077"
        ];
      };

      swapDevices = [
        { device = "/dev/disk/by-uuid/1322678f-b01e-4758-b08f-4f86338044d4"; }
      ];
      networking.useDHCP = lib.mkDefault true;
      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };

in
{ inputs, ... }: {
  flake.nixosConfigurations.constLaptopTUF = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      inputs.home-manager.nixosModules.home-manager
      ../configuration.nix
      host-configuration
    ];
  };
}
