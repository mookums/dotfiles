require('telescope')

local builtin = require('telescope.builtin')

vim.keymap.set('n', ',ff', builtin.find_files, {}) 
