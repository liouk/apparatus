vim.opt.ttimeoutlen = 0
vim.opt.nu = true
vim.opt.scrolloff = 8

vim.opt.swapfile = false
vim.opt.backup = false

-- identation
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true

-- search highlighting
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- colors
vim.opt.colorcolumn = "80"
vim.opt.termguicolors = true
vim.cmd([[
highlight ExtraWhitespace ctermbg=darkblue guibg=#494d64
autocmd BufEnter * exe ':2match ExtraWhitespace /\s\+$\| \+\ze\t\|\t\+\ze /'
]])

-- cursor: block everywhere, underline in insert
vim.opt.guicursor = 'a:block,i:hor50'

-- leader key
vim.g.mapleader = ','
