-- lazy.nvim Package Manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	-- Color Schemes
	{'stevedylandev/flexoki-nvim', name = 'flexoki'},
    {'folke/tokyonight.nvim'},
	-- Plugins
	{'nvim-telescope/telescope.nvim', tag = '0.1.4',
	 dependencies = {'nvim-lua/plenary.nvim' }
 	},
	{"nvim-tree/nvim-tree.lua", 
	 dependencies = {"nvim-tree/nvim-web-devicons"}
	},
	-- Language Support
	{'VonHeikemen/lsp-zero.nvim', branch = 'v3.x',
	 dependencies = {
		-- LSP Support
		{'williamboman/mason.nvim'},
		{'williamboman/mason-lspconfig.nvim'},
		{'neovim/nvim-lspconfig'},
		-- AutoComplete
		{'hrsh7th/cmp-nvim-lsp'},
		{'hrsh7th/nvim-cmp'},
		-- Snippets
		{'L3MON4D3/LuaSnip'},
	 },
 	},
	{"nvim-treesitter/nvim-treesitter", run = ':TSUpdate'},
})
