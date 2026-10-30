{ config, lib, pkgs, ... }: {
  imports = [ ./claude.nix ];
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
      ignores = [ "**/.claude/settings.local.json" ];
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
    # 확장은 선언하지 않는다 — nixpkgs판이 마켓플레이스보다 뒤처져
    # (vsrocq, claude-code 등) 선언하면 오히려 내려간다. 확장은
    # ~/.vscode/extensions에서 VS Code가 직접 관리한다.
    # 설정은 읽기 전용 링크라 설정 UI에서 바꾼 값은 저장되지 않는다 —
    # dotfiles/vscode-settings.json을 고칠 것.
    vscode = {
      enable = true;
      profiles.default = {
        userSettings = lib.importJSON ./dotfiles/vscode-settings.json;
        keybindings = lib.importJSON ./dotfiles/vscode-keybindings.json;
      };
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
          POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
          source ${./dotfiles/p10k.zsh}
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
      configFile = {
        "cabal/config".source = ./dotfiles/cabal-config;
        "kitty/kitty.conf".source = ./dotfiles/kitty.conf;
        "zellij/config.kdl".source = ./dotfiles/zellij.kdl;
      };
    };
}
