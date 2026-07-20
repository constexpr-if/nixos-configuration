{ pkgs, ... }: {
  username = "constexpr12";
  homeDirectory = "/home/constexpr12";
  packages = import ../source/packages.nix { inherit pkgs; };
}
