vim.o.number = true
vim.o.relativenumber = true
vim.o.numberwidth = 6
vim.go.cmdheight = 0
vim.opt.mouse = ""
vim.cmd("colorscheme kanagawa")

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("lsp", { clear = true }),
	callback = function(args)
		vim.api.nvim_create_autocmd("BufWritePre", {
			buffer = args.buf,
			callback = function()
				vim.lsp.buf.format { async = false, id = args.data.client_id }
			end,
		})
	end
})

local lspconfig = require("lspconfig")

local cmp = require("cmp")

local capabilities = require('cmp_nvim_lsp').default_capabilities()
vim.g.haskell_tools = {
	hls = {
		settings = {
			formattingProvider = "ormolu"
		}
	}
}

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
	settings = {
		Lua = {
			format = {
				enable = true,
				indent_style = "space",
				indent_size = "2",
			},
		}
	},
}
lspconfig.cmake.setup {
	capabilities = capabilities,
}
lspconfig.rust_analyzer.setup({
	settings = {
		['rust-analyzer'] = {
			check = {
				command = "clippy"
			},
		}
	}
})


require('lualine').setup()
require('goto-preview').setup()
