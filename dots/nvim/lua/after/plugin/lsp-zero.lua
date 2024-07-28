local lsp_zero = require('lsp-zero')
local lspconfig = require("lspconfig")

lsp_zero.on_attach(function(client, bufnr)
    lsp_zero.default_keymaps({ buffer = bufnr })
end)

local cmp = require('cmp')

cmp.setup({
    mapping = {
        ["<CR>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
    },
})

lspconfig.lua_ls.setup({
    settings = {
        Lua = {
            diagnostics = {
                globals = { "vim" },
            },
        },
    },
})

lspconfig.rust_analyzer.setup({
    settings = {
        ["rust-analyzer"] = {
            check = {
                command = "clippy",
            }
        },
    },
})

