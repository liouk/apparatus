vim.opt.ttimeoutlen = 0
vim.wo.number = true
vim.opt.scrolloff = 8
vim.wo.signcolumn = 'yes'
vim.o.updatetime = 250

-- utility files
vim.opt.swapfile = false
vim.opt.backup = false
vim.o.undofile = true

-- identation
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true

-- search
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.o.ignorecase = true
vim.o.smartcase = true

-- disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- colors
vim.opt.colorcolumn = '80'
vim.opt.termguicolors = true
vim.cmd([[
highlight ExtraWhitespace ctermbg=darkblue guibg=#494d64
autocmd BufEnter * exe ':2match ExtraWhitespace /\s\+$\| \+\ze\t\|\t\+\ze /'
]])

-- cursor: block everywhere, underline in insert
vim.opt.guicursor = 'a:block,i:hor50'

vim.g.mapleader = ','
vim.g.maplocalleader = ','
