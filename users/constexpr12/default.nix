{ config, pkgs, ... }: {
  dconf = {
    settings = {
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = [ "qemu:///system" ];
        uris = [ "qemu:///system" ];
      };
    };
  };
  home = {
    username = "constexpr12";
    homeDirectory = "/home/constexpr12";
    packages = import ./packages.nix { inherit pkgs; };
  };
  programs = {
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
    firefox = {
      enable = true;
    };
    # Terminal for the sway-console hangul TTY (modules/hangul-console.nix).
    foot = {
      enable = true;
      settings.main.font = "Iosevka Nerd Font:size=12, Noto Sans Mono CJK KR:size=12";
    };
    git = {
      enable = true;
      settings = {
        user = {
          name = "constexpr-if";
          email = "constexpr12@gmail.com";
        };
        safe.directory = "/etc/nixos";
      };
    };
    home-manager = {
      enable = true;
    };
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      plugins = with pkgs.vimPlugins; [
        cmp-nvim-lsp
        nvim-treesitter.withAllGrammars
        nvim-cmp
        nvim-lint
        nvim-lspconfig
        ultisnips

        goto-preview
        kanagawa-nvim
        lualine-nvim
        nvim-web-devicons

        Coqtail
        haskell-tools-nvim
      ];
      initLua = builtins.readFile ./init.lua;
      withRuby = true;
      withPython3 = true;
    };
    vscode = {
      enable = true;
    };
    zsh =
      let
        p10k = {
          name = "romkatv/powerlevel10k";
          tags = [
            "as:theme"
            "depth:1"
          ];
        };
      in
      {
        enable = true;
        enableVteIntegration = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        initContent = ''
          source ~/.p10k.zsh
          alias ls="ls --color=auto"
        '';
        zplug = {
          enable = true;
          plugins = [
            p10k
          ];
        };
      };
  };
  xdg =
    let
      HOME = config.home.homeDirectory;
    in
    {
      enable = true;
      cacheHome = "${HOME}/.cache";
      configHome = "${HOME}/.config";
      dataHome = "${HOME}/.local/share";
      stateHome = "${HOME}/.local/state";
    };
}
