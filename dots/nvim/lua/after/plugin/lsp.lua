local lspconfig = require("lspconfig")
local cmp = require('cmp')

cmp.setup({
    sources = {
        { name = 'nvim_lsp' },
    },
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({}),
})

vim.opt.signcolumn = 'yes'

local lspconfig_defaults = require('lspconfig').util.default_config
lspconfig_defaults.capabilities = vim.tbl_deep_extend(
    'force',
    lspconfig_defaults.capabilities,
    require('cmp_nvim_lsp').default_capabilities()
)

vim.api.nvim_create_autocmd('LspAttach', {
    desc = 'LSP actions',
    callback = function(event)
        local opts = { buffer = event.buf }

        vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
        vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
        vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
        vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
        vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
        vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
        vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
        vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
        vim.keymap.set({ 'n', 'x' }, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
        vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
    end,
})

local server_configurations = {
    nil_ls = {
        settings = {
            ['nil'] = {
                formatting = {
                    command = { "nixfmt" }
                }
            }
        }
    },
    rust_analyzer = {
        settings = {
            ["rust-analyzer"] = {
                check = {
                    command = "clippy",
                }
            }
        }
    },
    lua_ls = {
        settings = {
            Lua = {
                runtime = {
                    version = 'LuaJIT',
                    path = vim.split(package.path, ';'),
                },
                diagnostics = {
                    globals = { 'vim' },
                },
                workspace = {
                    library = {
                        [vim.fn.expand('$VIMRUNTIME/lua')] = true,
                        [vim.fn.expand('$VIMRUNTIME/lua/vim')] = true,
                    },
                },
                telemetry = {
                    enable = false,
                },
            }
        }
    },
}

local function setup_lsp_servers()
    -- Setup whichever we have in our path.
    -- This makes it easy to use nix shells and still have LSPs.
    local servers = {
        'ts_ls',         -- TS/JS
        'clangd',        -- C/C++
        'rust_analyzer', -- Rust
        'zls',           -- Zig
        'jdtls',         -- Java
        'lua_ls',        -- Lua
        'nil_ls',        -- Nix
        'csharp_ls',     -- C#
        'pylsp'          -- Python
    }

    for _, server in ipairs(servers) do
        local executable = vim.fn.executable(server)
        if executable then
            local config = server_configurations[server] or {}
            lspconfig[server].setup(config)
        end
    end
end

-- Setup LSP Servers
setup_lsp_servers()
