{ pkgs, ... }: let
  p10k = {
    name = "romkatv/powerlevel10k";
    tags = [ as:theme depth:1 ];
  };
in {
  programs = {
    zsh = {
      enable = true;
      enableVteIntegration = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      initExtra = ''
        source ~/.p10k.zsh
        alias ls="ls --color=auto"
      '';
      zplug = {
        enable = true;
        plugins = [
          p10k
        ];
      };
      oh-my-zsh = {
        enable = true;
        plugins = [];
      };
    };
  };
}
