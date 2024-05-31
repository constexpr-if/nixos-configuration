{ pkgs, ... }: {
  programs.vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [];
    extraConfig = ''
      set number
      set numberwidth=6
      colorscheme slate
      if has("syntax")
        syntax on
      endif
    '';
  };
}