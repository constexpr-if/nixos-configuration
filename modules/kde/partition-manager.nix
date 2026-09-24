{ config, lib, ... }:
{
  config = lib.mkIf config.kdepackages.partition-manager.enable {
    programs.partition-manager.enable = true;
  };
}
