vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.termguicolors = true

require("neo-tree").setup({
    window = {
        position = "current",
    }
})

vim.keymap.set('n', '<leader>tt', ":Neotree toggle<CR>", {})
vim.keymap.set('n', '<leader>tf', ":Neotree focus<CR>", {})
