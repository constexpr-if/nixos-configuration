{
  boot.supportedFilesystems = [ "ntfs" ];
  fileSystems."/home/constexpr12/Xref" = {
    device = "/dev/disk/by-uuid/5BAD0F463D1F01B5";
    fsType = "ntfs";
    options = [
      "uid=1001"
      "gid=100"
      "nofail"
    ];
  };
}
