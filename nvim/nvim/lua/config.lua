-- disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true
vim.cmd.colorscheme "catppuccin-macchiato"

-- cursor: block everywhere, underline in insert
vim.opt.guicursor = 'a:block,i:hor50'

-- leader key
vim.g.mapleader = ','
