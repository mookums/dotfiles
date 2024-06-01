local lsp_zero = require('lsp-zero')
local lspconfig = require("lspconfig")

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
        -- Use Default
        lsp_zero.default_setup,
        -- For Lua, we want vim as a global
        ["lua_ls"] = function()
            lspconfig.lua_ls.setup({
                settings = {
                    Lua = {
                        diagnostics = {
                            globals = { "vim" },
                        },
                    },
                },
            })
        end,
        -- For Rust, we want to use Clippy
        ["rust_analyzer"] = function()
            lspconfig.rust_analyzer.setup({
                settings = {
                    ["rust-analyzer"] = {
                        check = {
                            command = "clippy",
                        }
                    },
                },
            })
        end
    },
})
