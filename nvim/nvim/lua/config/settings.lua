vim.opt.ttimeoutlen = 0
vim.opt.swapfile = false
vim.wo.number = true

-- identation
vim.opt.smartindent = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2

-- disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- colors
vim.opt.termguicolors = true
vim.cmd([[
highlight ExtraWhitespace ctermbg=darkblue guibg=#494d64
autocmd BufEnter * exe ':2match ExtraWhitespace /\s\+$\| \+\ze\t\|\t\+\ze /'
]])

-- cursor: block everywhere, underline in insert
vim.opt.guicursor = 'a:block,i:hor50'

-- leader key
vim.g.mapleader = ','
