{
  home.username = "constexpr12";
  home.homeDirectory = "/home/constexpr12";
  home.stateVersion = "23.11";
  imports = [
    ./boot.nix
    ./packages.nix
    ./virt-manager.nix
    ./programs/chromium.nix
    ./programs/git.nix
    ./programs/vim.nix
  ];
  programs.home-manager.enable = true;
}
