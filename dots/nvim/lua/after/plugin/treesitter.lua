require('nvim-treesitter.configs').setup({
    ensure_installed = "all",
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
    --indent = {
    --    enable = true,  -- Enable Treesitter-based indentation
    --},
    -- Other TreeSitter modules can be enabled here
})

