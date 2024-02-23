require('nvim-treesitter.configs').setup({
    ensure_installed = {
        "bash",
        "c",
        "lua",
        "go",
        "java",
        "javascript",
        "typescript",
        "zig",
        "rust"
    },
    sync_install = false,
    auto_install = true,

    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
})
