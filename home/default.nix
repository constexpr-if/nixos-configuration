{
    home.username = "constexpr12";
    home.homeDirectory = "/home/constexpr12";
    home.stateVersion = "23.11";
    imports = [
      ./vim.nix
      ./git.nix
      ./chromium.nix
      ./packages.nix
    ];
    programs.home-manager.enable = true;
}
