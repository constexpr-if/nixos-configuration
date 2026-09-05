{ pkgs, ... }: {
  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = true;
    systemd-boot.configurationLimit = 10;
  };
  boot.supportedFilesystems = {
    vfat = true;
    ext4 = true;
    exfat = true;
    # tmpfs = true;
    ntfs = false;
  };
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  # Root-needed disk tools only; everything else lives in
  # users/constexpr12/packages.nix (home-manager).
  environment.systemPackages = with pkgs; [
    gparted
    parted
  ];
  fonts.packages = with pkgs; [
    nerd-fonts.iosevka
    noto-fonts-cjk-sans
    pretendard
  ];
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "backup";
    users.constexpr12 = {
      imports = [
        ./users/constexpr12
      ];
    };
    sharedModules = [ ];
  };
  i18n = {
    defaultLocale = "ko_KR.UTF-8";
    inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5.waylandFrontend = true;
      fcitx5.addons = with pkgs; [
        fcitx5-hangul
      ];
    };
    extraLocaleSettings = {
      LC_CTYPE = "ko_KR.UTF-8";
      LC_NUMERIC = "ko_KR.UTF-8";
      LC_TIME = "ko_KR.UTF-8";
      LC_COLLATE = "ko_KR.UTF-8";
      LC_MONETARY = "ko_KR.UTF-8";
      LC_MESSAGES = "ko_KR.UTF-8";
      LC_PAPER = "ko_KR.UTF-8";
      LC_NAME = "ko_KR.UTF-8";
      LC_ADDRESS = "ko_KR.UTF-8";
      LC_TELEPHONE = "ko_KR.UTF-8";
      LC_MEASUREMENT = "ko_KR.UTF-8";
      LC_IDENTIFICATION = "ko_KR.UTF-8";
    };
  };
  networking = {
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
    ];
    firewall = {
      enable = true;
      # Tailnet peers are authenticated by the overlay itself.
      trustedInterfaces = [ "tailscale0" ];
    };
    networkmanager.enable = true;
  };
  nixpkgs.config.allowUnfree = true;
  programs = {
    zsh.enable = true;
    nix-ld.enable = true;
    virt-manager = {
      enable = true;
    };
    steam = {
      enable = true;
    };
  };
  security.rtkit.enable = true;
  services = {
    xserver = {
      enable = true;
      excludePackages = [ pkgs.xterm ];
    };
    desktopManager.plasma6.enable = true;
    displayManager.defaultSession = "plasma";
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
    cloudflare-warp.enable = true;
    journald.extraConfig = "SystemMaxUse=300M";
    # Overlay network: phone/laptop reach this and each host without port
    # forwarding. Migration plan: run alongside the existing 22/8434
    # forwards first, close them at the router once tailnet proves stable.
    tailscale.enable = true;
    seatd.enable = true; # dependency of gamescope
    # The kernel console is limited to 512 glyphs and cannot render CJK;
    # kmscon replaces the VT gettys with a userspace console that can.
    kmscon = {
      enable = true;
      fonts = [
        {
          name = "Iosevka Nerd Font";
          package = pkgs.nerd-fonts.iosevka;
        }
        {
          name = "Noto Sans Mono CJK KR";
          package = pkgs.noto-fonts-cjk-sans;
        }
      ];
      extraConfig = "font-size=14";
    };
  };
  time.timeZone = "Asia/Seoul";
  users.users.constexpr12 = {
    isNormalUser = true;
    home = "/home/constexpr12";
    extraGroups = [
      "libvirtd"
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
  };
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      swtpm.enable = true;
    };
  };
  virtualisation.waydroid.enable = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nix.optimise.automatic = true;
  nix.settings = {
    substituters = [
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
}
