-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions

local lspconfig = require('lspconfig')


local capabilities = require('cmp_nvim_lsp').default_capabilities()

lspconfig['zls'].setup({
	capabilities = capabilities,
  	cmd = {
    		"zls",
    		"--enable-debug-log",
  	},
	filetypes = {"zig"},
})
