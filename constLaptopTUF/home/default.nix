let
  constexpr12 = import ../../users/constexpr12.nix;
in
{
  imports = [
    ../../modules/home-manager.nix
  ];

  home-manager.users.constexpr12 = constexpr12 {
    stateVersion = "25.05";
  };
}
