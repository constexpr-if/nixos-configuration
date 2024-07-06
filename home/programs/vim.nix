{ pkgs, ... }: {
  programs.vim = {
    enable = true;
    defaultEditor = true;
    plugins = with pkgs.vimPlugins; [
      Coqtail
    ];
    extraConfig = ''
      set number relativenumber numberwidth=6
      set nowrap
      colorscheme slate
      if has("syntax")
        syntax on
      endif
    '';
  };
}
