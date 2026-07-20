{ self, haumea, ... }: {
  users.constexpr12 = {
    imports = [
      (haumea ../constexpr12)
    ];
    home.stateVersion = "25.11";
  };
}
