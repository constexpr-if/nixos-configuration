{ haumea, ... }: {
  useGlobalPkgs = true;
  useUserPackages = true;
  backupFileExtension = "backup";
  users.constexpr12 = {
    imports = [
      ../users/constexpr12
    ];
  };
  extraSpecialArgs = { inherit haumea; };
}
