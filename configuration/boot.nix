{
  loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = true;
  };
  supportedFilesystems = {
    fat32 = true;
    ext4 = true;
    exfat = true;
    # tmpfs = true;
    ntfs = false;
  };
}
