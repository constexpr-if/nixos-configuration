{ ... }:
let
  name = "Projects";
in
{
  services.mutagen.enable = true;
  services.mutagen.sync.${name} = {
    alpha = "~/${name}";
    beta = "shared_fs:${name}";
    flags = {
      mode = "two-way-resolved";
      ignore = [
        ".direnv"
      ];
    };
  };
}
