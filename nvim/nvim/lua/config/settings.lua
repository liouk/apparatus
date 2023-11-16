vim.opt.ttimeoutlen = 0
vim.opt.scrolloff = 8
vim.o.updatetime = 250

-- status column
vim.wo.number = true
vim.wo.numberwidth = 3
vim.wo.signcolumn = 'yes'

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
vim.opt.termguicolors = true
-- highlight extra whitespace except for the dashboard (alpha)
vim.cmd([[
highlight ExtraWhitespace ctermbg=darkblue guibg=#494d64
autocmd FileType * if &ft!="alpha" | execute ':2match ExtraWhitespace /\s\+$\| \+\ze\t\|\t\+\ze /' | endif
]])

-- cursor: block everywhere, underline in insert
vim.opt.guicursor = 'a:block,i:hor50'

vim.g.mapleader = ','
vim.g.maplocalleader = ','
