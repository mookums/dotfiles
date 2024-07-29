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

local function setup_lsp_servers()
    -- Setup whichever we have in our path.
    -- This makes it easy to use nix shells and still have LSPs.
    local servers = {
        'tsserver',         -- TS/JS
        'clangd',           -- C/C++
        'rust_analyzer',    -- Rust
        'zls',              -- Zig
        'jdtls',            -- Java
        'lua_ls'            -- Lua
    }

    for _, server in ipairs(servers) do
        local executable = vim.fn.executable(server)
        if executable then
            lspconfig[server].setup {}
        end
    end
end

-- Setup LSP Servers
setup_lsp_servers()
