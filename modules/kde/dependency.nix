{
  pkgs,
  kdePackages ? pkgs.kdePackages,
  ...
}:
rec {
  sddm = {
    name = "sddm";
    depends = [ ];
    package = null;
  };
  plasma = {
    name = "plasma";
    depends = [ sddm ];
    package = null;
  };
  partition-manager = {
    name = "partition-manager";
    depends = [ ];
    package = null;
  };

  baloo-widgets = {
    name = "baloo-widgets";
    depends = [ ];
    package = kdePackages.baloo-widgets;
  };
  dolphin = {
    name = "dolphin";
    depends = [
      baloo-widgets
      dolphin-plugins
      ffmpegthumbs
      konsole
    ];
    package = kdePackages.dolphin;
  };
  dolphin-plugins = {
    name = "dolphin-plugins";
    depends = [ ];
    package = kdePackages.dolphin-plugins;
  };
  ffmpegthumbs = {
    name = "ffmpegthumbs";
    depends = [ ];
    package = kdePackages.ffmpegthumbs;
  };
  konsole = {
    name = "konsole";
    depends = [ ];
    package = kdePackages.konsole;
  };
  okular = {
    name = "okular";
    depends = [ ];
    package = kdePackages.okular;
  };
  plasma-systemmonitor = {
    name = "plasma-systemmonitor";
    depends = [ plasma ];
    package = kdePackages.plasma-systemmonitor;
  };
  spectacle = {
    name = "spectacle";
    depends = [ plasma ];
    package = kdePackages.spectacle;
  };

  akonadi = {
    name = "akonadi";
    depends = [ ];
    package = kdePackages.akonadi;
  };
  akonadi-calendar-tools = {
    name = "akonadi-calendar-tools";
    depends = [
      akonadi
    ];
    package = kdePackages.akonadi-calendar-tools;
  };
  akonadi-contacts = {
    name = "akonadi-contacts";
    depends = [ ];
    package = kdePackages.akonadi-contacts;
  };
  akonadi-import-wizard = {
    name = "akonadi-import-wizard";
    depends = [
      akonadi
    ];
    package = kdePackages.akonadi-import-wizard;
  };
  akonadiconsole = {
    name = "akonadiconsole";
    depends = [
      akonadi
    ];
    package = kdePackages.akonadiconsole;
  };
  akregator = {
    name = "akregator";
    depends = [
      akonadi
    ];
    package = kdePackages.akregator;
  };
  applet-window-buttons6 = {
    name = "applet-window-buttons6";
    depends = [
      plasma
    ];
    package = kdePackages.applet-window-buttons6;
  };
  aurorae = {
    name = "aurorae";
    depends = [
      kwin
    ];
    package = kdePackages.aurorae;
  };
  baloo = {
    name = "baloo";
    depends = [ ];
    package = kdePackages.baloo;
  };
  bluedevil = {
    name = "bluedevil";
    depends = [
      plasma
    ];
    package = kdePackages.bluedevil;
  };
  dynamic-workspaces = {
    name = "dynamic-workspaces";
    depends = [
      kwin
    ];
    package = kdePackages.dynamic-workspaces;
  };
  fcitx5-chinese-addons = {
    name = "fcitx5-chinese-addons";
    depends = [
      fcitx5-with-addons
    ];
    package = kdePackages.fcitx5-chinese-addons;
  };
  fcitx5-configtool = {
    name = "fcitx5-configtool";
    depends = [
      fcitx5-with-addons
    ];
    package = kdePackages.fcitx5-configtool;
  };
  fcitx5-skk-qt = {
    name = "fcitx5-skk-qt";
    depends = [
      fcitx5-with-addons
    ];
    package = kdePackages.fcitx5-skk-qt;
  };
  fcitx5-unikey = {
    name = "fcitx5-unikey";
    depends = [
      fcitx5-with-addons
    ];
    package = kdePackages.fcitx5-unikey;
  };
  fcitx5-with-addons = {
    name = "fcitx5-with-addons";
    depends = [ ];
    package = kdePackages.fcitx5-with-addons;
  };
  flatpak-kcm = {
    name = "flatpak-kcm";
    depends = [
      systemsettings
    ];
    package = kdePackages.flatpak-kcm;
  };
  kaccounts-integration = {
    name = "kaccounts-integration";
    depends = [ ];
    package = kdePackages.kaccounts-integration;
  };
  kaccounts-providers = {
    name = "kaccounts-providers";
    depends = [
      kaccounts-integration
    ];
    package = kdePackages.kaccounts-providers;
  };
  kactivitymanagerd = {
    name = "kactivitymanagerd";
    depends = [ ];
    package = kdePackages.kactivitymanagerd;
  };
  kaddressbook = {
    name = "kaddressbook";
    depends = [
      akonadi
      akonadi-contacts
    ];
    package = kdePackages.kaddressbook;
  };
  kalarm = {
    name = "kalarm";
    depends = [
      akonadi
    ];
    package = kdePackages.kalarm;
  };
  kdegraphics-mobipocket = {
    name = "kdegraphics-mobipocket";
    depends = [
      okular
    ];
    package = kdePackages.kdegraphics-mobipocket;
  };
  kdenetwork-filesharing = {
    name = "kdenetwork-filesharing";
    depends = [
      dolphin
    ];
    package = kdePackages.kdenetwork-filesharing;
  };
  kdepim-addons = {
    name = "kdepim-addons";
    depends = [
      kaddressbook
      kmail
      kontact
      korganizer
    ];
    package = kdePackages.kdepim-addons;
  };
  kdepim-runtime = {
    name = "kdepim-runtime";
    depends = [
      akonadi
    ];
    package = kdePackages.kdepim-runtime;
  };
  kdeplasma-addons = {
    name = "kdeplasma-addons";
    depends = [
      plasma
    ];
    package = kdePackages.kdeplasma-addons;
  };
  kdev-php = {
    name = "kdev-php";
    depends = [
      kdevelop
    ];
    package = kdePackages.kdev-php;
  };
  kdev-python = {
    name = "kdev-python";
    depends = [
      kdevelop
    ];
    package = kdePackages.kdev-python;
  };
  kdevelop = {
    name = "kdevelop";
    depends = [ ];
    package = kdePackages.kdevelop;
  };
  kglobalaccel = {
    name = "kglobalaccel";
    depends = [
      kglobalacceld
    ];
    package = kdePackages.kglobalaccel;
  };
  kglobalacceld = {
    name = "kglobalacceld";
    depends = [ ];
    package = kdePackages.kglobalacceld;
  };
  kio-gdrive = {
    name = "kio-gdrive";
    depends = [
      kaccounts-integration
    ];
    package = kdePackages.kio-gdrive;
  };
  kmail = {
    name = "kmail";
    depends = [
      akonadi
      kdepim-runtime
    ];
    package = kdePackages.kmail;
  };
  kmail-account-wizard = {
    name = "kmail-account-wizard";
    depends = [
      kmail
    ];
    package = kdePackages.kmail-account-wizard;
  };
  koi = {
    name = "koi";
    depends = [
      plasma
    ];
    package = kdePackages.koi;
  };
  kontact = {
    name = "kontact";
    depends = [
      kaddressbook
      kmail
      korganizer
    ];
    package = kdePackages.kontact;
  };
  korganizer = {
    name = "korganizer";
    depends = [
      akonadi
    ];
    package = kdePackages.korganizer;
  };
  krohnkite = {
    name = "krohnkite";
    depends = [
      kwin
    ];
    package = kdePackages.krohnkite;
  };
  kscreenlocker = {
    name = "kscreenlocker";
    depends = [ ];
    package = kdePackages.kscreenlocker;
  };
  ksshaskpass = {
    name = "ksshaskpass";
    depends = [
      kwallet
    ];
    package = kdePackages.ksshaskpass;
  };
  kwallet = {
    name = "kwallet";
    depends = [ ];
    package = kdePackages.kwallet;
  };
  kwallet-pam = {
    name = "kwallet-pam";
    depends = [
      kwallet
    ];
    package = kdePackages.kwallet-pam;
  };
  kwalletmanager = {
    name = "kwalletmanager";
    depends = [
      kwallet
    ];
    package = kdePackages.kwalletmanager;
  };
  kwin = {
    name = "kwin";
    depends = [ ];
    package = kdePackages.kwin;
  };
  kzones = {
    name = "kzones";
    depends = [
      kwin
    ];
    package = kdePackages.kzones;
  };
  mbox-importer = {
    name = "mbox-importer";
    depends = [
      akonadi
    ];
    package = kdePackages.mbox-importer;
  };
  merkuro = {
    name = "merkuro";
    depends = [
      akonadi
      kdepim-runtime
    ];
    package = kdePackages.merkuro;
  };
  milou = {
    name = "milou";
    depends = [
      baloo
    ];
    package = kdePackages.milou;
  };
  phonon = {
    name = "phonon";
    depends = [ ];
    package = kdePackages.phonon;
  };
  phonon-vlc = {
    name = "phonon-vlc";
    depends = [
      phonon
    ];
    package = kdePackages.phonon-vlc;
  };
  pim-data-exporter = {
    name = "pim-data-exporter";
    depends = [
      akonadi
    ];
    package = kdePackages.pim-data-exporter;
  };
  pim-sieve-editor = {
    name = "pim-sieve-editor";
    depends = [
      akonadi
    ];
    package = kdePackages.pim-sieve-editor;
  };
  plasma-browser-integration = {
    name = "plasma-browser-integration";
    depends = [
      plasma
    ];
    package = kdePackages.plasma-browser-integration;
  };
  plasma-desktop = {
    name = "plasma-desktop";
    depends = [
      kactivitymanagerd
      plasma-workspace
    ];
    package = kdePackages.plasma-desktop;
  };
  plasma-disks = {
    name = "plasma-disks";
    depends = [
      plasma
    ];
    package = kdePackages.plasma-disks;
  };
  plasma-login-manager = {
    name = "plasma-login-manager";
    depends = [
      sddm
    ];
    package = kdePackages.plasma-login-manager;
  };
  plasma-mobile = {
    name = "plasma-mobile";
    depends = [
      plasma-workspace
    ];
    package = kdePackages.plasma-mobile;
  };
  plasma-nano = {
    name = "plasma-nano";
    depends = [
      plasma-workspace
    ];
    package = kdePackages.plasma-nano;
  };
  plasma-nm = {
    name = "plasma-nm";
    depends = [
      plasma
    ];
    package = kdePackages.plasma-nm;
  };
  plasma-pa = {
    name = "plasma-pa";
    depends = [
      plasma
    ];
    package = kdePackages.plasma-pa;
  };
  plasma-pass = {
    name = "plasma-pass";
    depends = [
      plasma
    ];
    package = kdePackages.plasma-pass;
  };
  plasma-thunderbolt = {
    name = "plasma-thunderbolt";
    depends = [
      plasma
    ];
    package = kdePackages.plasma-thunderbolt;
  };
  plasma-vault = {
    name = "plasma-vault";
    depends = [
      plasma
    ];
    package = kdePackages.plasma-vault;
  };
  plasma-workspace = {
    name = "plasma-workspace";
    depends = [
      kactivitymanagerd
      kscreenlocker
      kwin
    ];
    package = kdePackages.plasma-workspace;
  };
  sddm-kcm = {
    name = "sddm-kcm";
    depends = [
      sddm
      systemsettings
    ];
    package = kdePackages.sddm-kcm;
  };
  sierra-breeze-enhanced = {
    name = "sierra-breeze-enhanced";
    depends = [
      kwin
    ];
    package = kdePackages.sierra-breeze-enhanced;
  };
  signon-kwallet-extension = {
    name = "signon-kwallet-extension";
    depends = [
      kwallet
      signond
    ];
    package = kdePackages.signon-kwallet-extension;
  };
  signond = {
    name = "signond";
    depends = [ ];
    package = kdePackages.signond;
  };
  systemsettings = {
    name = "systemsettings";
    depends = [ ];
    package = kdePackages.systemsettings;
  };
  wacomtablet = {
    name = "wacomtablet";
    depends = [
      systemsettings
    ];
    package = kdePackages.wacomtablet;
  };
  wallpaper-engine-plugin = {
    name = "wallpaper-engine-plugin";
    depends = [
      plasma
    ];
    package = kdePackages.wallpaper-engine-plugin;
  };
  yakuake = {
    name = "yakuake";
    depends = [
      konsole
    ];
    package = kdePackages.yakuake;
  };
  zanshin = {
    name = "zanshin";
    depends = [
      akonadi
    ];
    package = kdePackages.zanshin;
  };
}
