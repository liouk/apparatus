-- global variables
vim.g.nvim_ide = false
vim.g.sessions_path = vim.fn.stdpath('data') .. '/sessions'

-- configuration
require('config.settings')
require('config.keymaps')
require('config.lazy')
