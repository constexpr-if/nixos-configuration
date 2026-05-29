{ pkgs, ... }:
{
  programs.neovim = {
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
    extraLuaConfig = builtins.readFile ./init.lua;
  };
}
