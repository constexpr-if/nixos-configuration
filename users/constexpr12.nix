{ stateVersion }:
{
  home = {
    username = "constexpr12";
    homeDirectory = "/home/constexpr12";
    inherit stateVersion;
  };
  imports = [
    ../home/packages.nix
    ../home/virt-manager.nix
    ../home/programs/direnv.nix
    ../home/programs/firefox.nix
    ../home/programs/git.nix
    ../home/programs/neovim
    ../home/programs/vscode.nix
    ../home/programs/zsh.nix
  ];
  programs.home-manager.enable = true;
}
