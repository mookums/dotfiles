vim.g.loaded_netrw = 1
vim.gloaded_netrwPlugin = 1

vim.opt.termguicolors = true

require("nvim-tree").setup()

local api = require("nvim-tree.api")

vim.keymap.set('n', ',tt', api.tree.toggle, {})
vim.keymap.set('n', ',tf', api.tree.focus, {})
