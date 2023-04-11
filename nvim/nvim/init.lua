-- global variables
vim.g.sessions_path = vim.fn.stdpath('data') .. '/sessions'

-- configuration
require('config.settings')
require('config.keymaps')
require('config.lazy')
require('user.gitlinks')
