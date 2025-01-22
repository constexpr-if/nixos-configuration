{
  home.username = "constexpr12";
  home.homeDirectory = "/home/constexpr12";
  imports = [
    ./boot.nix
    ./packages.nix
    ./virt-manager.nix
    ./programs/chromium.nix
    ./programs/direnv.nix
    ./programs/git.nix
    ./programs/neovim
    ./programs/vscode.nix
    ./programs/zsh.nix
  ];
  programs.home-manager.enable = true;
}
