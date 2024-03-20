vim.g.loaded_netrw = 1
vim.gloaded_netrwPlugin = 1

vim.opt.termguicolors = true

require("nvim-tree").setup()

local api = require("nvim-tree.api")

vim.keymap.set('n', '<leader>tt', api.tree.toggle, {})
vim.keymap.set('n', '<leader>tf', api.tree.focus, {})
