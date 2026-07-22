{ libpp, ... }: with libpp;
{
  users.constexpr12 = {
    imports = [
      (haumea-module ../constexpr12)
    ];
    home.stateVersion = "25.11";
  };
}
