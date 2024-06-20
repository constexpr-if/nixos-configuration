{ pkgs, ... }: {
  programs.vim = {
    enable = true;
    defaultEditor = true;
    plugins = with pkgs.vimPlugins; [
      Coqtail
    ];
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
