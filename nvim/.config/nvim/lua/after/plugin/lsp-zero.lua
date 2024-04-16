local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
    -- see :help lsp-zero-keybindings
    -- to learn the available actions
    lsp_zero.default_keymaps({ buffer = bufnr })
end)

local cmp = require('cmp')

cmp.setup({
    mapping = {
        ["<CR>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
    },
}
)

require('mason').setup({})
require('mason-lspconfig').setup({
    ensure_installed = {
        "clangd",        -- C
        "rust_analyzer", -- Rust
        "lua_ls",        -- Lua
    },
    handlers = {
        lsp_zero.default_setup,
    },
})
