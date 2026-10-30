{ pkgs, ... }: {
  imports = [
    ./modules/kde
  ];
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
      # 설정 도구(GUI)로 바꾼 값은 저장되지 않는다 — ~/.config/fcitx5를
      # 무시하고 이 선언(/etc/xdg/fcitx5)만 읽는다. 바꾸려면 여기를 고칠 것.
      fcitx5.ignoreUserConfig = true;
      fcitx5.settings = {
        globalOptions = {
          Hotkey = {
            EnumerateWithTriggerKeys = "True";
            EnumerateBackwardKeys = "";
            EnumerateSkipFirst = "False";
            ModifierOnlyKeyTimeout = 250;
          };
          "Hotkey/TriggerKeys" = {
            "0" = "Alt+Alt_R";
            "1" = "Hangul";
          };
          "Hotkey/ActivateKeys"."0" = "Hangul_Hanja";
          "Hotkey/DeactivateKeys"."0" = "Hangul_Romaja";
          "Hotkey/AltTriggerKeys"."0" = "Shift_L";
          "Hotkey/EnumerateForwardKeys"."0" = "Hangul";
          "Hotkey/EnumerateGroupForwardKeys"."0" = "Super+space";
          "Hotkey/EnumerateGroupBackwardKeys"."0" = "Shift+Super+space";
          "Hotkey/PrevPage"."0" = "Up";
          "Hotkey/NextPage"."0" = "Down";
          "Hotkey/PrevCandidate"."0" = "Shift+Tab";
          "Hotkey/NextCandidate"."0" = "Tab";
          "Hotkey/TogglePreedit"."0" = "Control+Alt+P";
          Behavior = {
            ActiveByDefault = "False";
            resetStateWhenFocusIn = "No";
            ShareInputState = "No";
            PreeditEnabledByDefault = "True";
            ShowInputMethodInformation = "True";
            showInputMethodInformationWhenFocusIn = "False";
            CompactInputMethodInformation = "True";
            ShowFirstInputMethodInformation = "True";
            DefaultPageSize = 5;
            OverrideXkbOption = "False";
            CustomXkbOption = "";
            EnabledAddons = "";
            DisabledAddons = "";
            PreloadInputMethod = "True";
            AllowInputMethodForPassword = "False";
            ShowPreeditForPassword = "False";
            AutoSavePeriod = 30;
          };
        };
        inputMethod = {
          "Groups/0" = {
            Name = "기본값";
            "Default Layout" = "us";
            DefaultIM = "hangul";
          };
          "Groups/0/Items/0" = {
            Name = "keyboard-us";
            Layout = "";
          };
          "Groups/0/Items/1" = {
            Name = "hangul";
            Layout = "";
          };
          GroupOrder."0" = "기본값";
        };
        addons.hangul = {
          globalSection = {
            Keyboard = "Dubeolsik";
            AutoReorder = "True";
            WordCommit = "False";
            HanjaMode = "False";
          };
          sections = {
            HanjaModeToggleKey = {
              "0" = "Hangul_Hanja";
              "1" = "F9";
            };
            PrevPage."0" = "Up";
            NextPage."0" = "Down";
            PrevCandidate."0" = "Shift+Tab";
            NextCandidate."0" = "Tab";
          };
        };
      };
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
  kdepackages = {
    plasma.enable = true;
    dolphin.enable = true;
    okular.enable = true;
    partition-manager.enable = true;
    plasma-systemmonitor.enable = true;
    spectacle.enable = true;
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
      xkb = {
        layout = "us";
        options = "korean:ralt_hangul";
      };
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
