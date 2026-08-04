let
  host-configuration =
    { pkgs, ... }:
    {
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };
      hardware.amdgpu.opencl.enable = true;
      networking.hostName = "constDesktop";
      # TODO: Make module for this
      services.udev.extraRules = ''
        ACTION=="add" SUBSYSTEM=="usb" ATTR{idVendor}=="046d" ATTR{idProduct}=="c548" ATTR{power/wakeup}="disabled"
      '';
      services.lact.enable = true;
      home-manager.users.constexpr12 = { config, ... }: {
        programs = {
          firefox.configPath = "${config.xdg.configHome}/mozilla/firefox";
          zsh.dotDir = "${config.xdg.configHome}/zsh";
        };
        home.stateVersion = "25.11";
      };
      system.stateVersion = "23.11";
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
        "ahci"
        "usbhid"
      ];
      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ "kvm-amd" ];
      boot.extraModulePackages = [ ];

      fileSystems = {
        "/" = {
          device = "/dev/disk/by-uuid/ab18e99d-694e-41ac-bc46-5d861ed085d9";
          fsType = "ext4";
        };

        "/boot" = {
          device = "/dev/disk/by-uuid/549B-B032";
          fsType = "vfat";
          options = [
            "fmask=0022"
            "dmask=0022"
          ];
        };

        "/home" = {
          device = "/dev/disk/by-uuid/95a1f1eb-47e4-42fc-8963-c287d5ec56c1";
          fsType = "ext4";
        };

        "/nix/store" = {
          device = "/dev/disk/by-uuid/a52c5cb9-dea8-47fc-b28a-a61d3c15811f";
          fsType = "ext4";
          options = [ "noatime" ];
        };
      };

      swapDevices = [
        { device = "/dev/disk/by-uuid/343cd444-cd3e-4b30-a4b1-078c21e10377"; }
      ];

      # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
      # (the default) this is the recommended approach. When using systemd-networkd it's
      # still possible to use this option, but it's recommended to use it in conjunction
      # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
      networking.useDHCP = lib.mkDefault true;
      # networking.interfaces.enp7s0.useDHCP = lib.mkDefault true;

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
in
{ inputs, ... }: {
  flake.nixosConfigurations.constDesktop = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      inputs.home-manager.nixosModules.home-manager
      host-configuration
      hardware-configuration
      ../configuration.nix
    ];
  };
}
