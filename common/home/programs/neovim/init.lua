vim.o.number = true
vim.o.relativenumber = true
vim.o.numberwidth=6
vim.go.cmdheight = 0
vim.opt.mouse = ""
vim.cmd("colorscheme kanagawa")

local lspconfig = require("lspconfig")
local cmp = require("cmp")
local capabilities = require('cmp_nvim_lsp').default_capabilities()
local hstools = require('haskell-tools')
require("nvim-treesitter.configs").setup {
  highlight = {
    enable = true,
    disable = {},
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "gnn",
      node_incremental = "grn",
      scope_incremental = "grc",
      node_decremental = "grm",
    },
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
      },
    },
  },
}
cmp.setup {
    snippet = {
        expand = function(args)
            vim.fn["UltiSnips#Anon"](args.body)
        end
    },
    mapping = {
        ['<C-p>'] = cmp.mapping.select_prev_item(),
        ['<C-n>'] = cmp.mapping.select_next_item(),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
    },
    sources = {
      { name = 'nvim_lsp' },
      { name = 'ultisnips' },
      { name = 'buffer' },
      { name = 'path' },
    },
}
lspconfig.clangd.setup {
    capabilities = capabilities,
    cmd = {
        "clangd",
        "--background-index",
        "--suggest-missing-includes",
        "--clang-tidy",
        "--header-insertion=iwyu"
    }
}
lspconfig.nixd.setup {
    capabilities = capabilities,
}
lspconfig.ocamllsp.setup {
    capabilities = capabilities,
}
lspconfig.lua_ls.setup {
    capabilities = capabilities,
}


require('lualine').setup()
require('goto-preview').setup()
