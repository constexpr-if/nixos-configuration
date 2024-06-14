{
    home.username = "constexpr12";
    home.homeDirectory = "/home/constexpr12";
    home.stateVersion = "23.11";
    imports = [
      ./chromium.nix
      ./git.nix
      ./packages.nix
      ./vim.nix
      ./virt-manager.nix
    ];
    programs.home-manager.enable = true;
}
