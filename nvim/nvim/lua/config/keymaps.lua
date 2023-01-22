-- vim. live it.
vim.keymap.set('', '<up>', '<nop>', { desc = 'vim. live it.' })
vim.keymap.set('', '<down>', '<nop>', { desc = 'vim. live it.' })
vim.keymap.set('', '<left>', '<nop>', { desc = 'vim. live it.' })
vim.keymap.set('', '<right>', '<nop>', { desc = 'vim. live it.' })
vim.keymap.set('i', '<up>', '<nop>', { desc = 'vim. live it.' })
vim.keymap.set('i', '<down>', '<nop>', { desc = 'vim. live it.' })
vim.keymap.set('i', '<left>', '<nop>', { desc = 'vim. live it.' })
vim.keymap.set('i', '<right>', '<nop>', { desc = 'vim. live it.' })

-- splits
vim.keymap.set('n', '<C-e>', ':vsplit<CR>', { desc = 'Split vertically' })
vim.keymap.set('n', '<C-l>', ':wincmd l<CR>', { desc = 'Go to right window' })
vim.keymap.set('n', '<C-h>', ':wincmd h<CR>', { desc = 'Go to left window' })
vim.keymap.set('i', '<C-s>', '<Esc>:vsplit<CR>i', { desc = 'Split vertically' })
vim.keymap.set('i', '<C-l>', '<Esc>:wincmd l<CR>i', { desc = 'Go to right window' })
vim.keymap.set('i', '<C-h>', '<Esc>:wincmd h<CR>i', { desc = 'Split vertically' })

-- clipboard
vim.keymap.set('v', '<leader>y', '"+y', { desc = 'Copy to system clipboard' })
vim.keymap.set('n', '<leader>y', '"+y', { desc = 'Copy to system clipboard' })

-- cursor movements
vim.keymap.set('n', '<C-b>', '*``', { desc = 'Highlight word without moving' })
vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Move down keeping cursor at the middle of the screen' })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Move up keeping cursor at the middle of the screen' })
vim.keymap.set('n', 'n', 'nzz', { desc = 'Search forward keeping cursor at the middle of the screen' })
vim.keymap.set('n', 'N', 'Nzz', { desc = 'Search backward keeping cursror at the middle of the screen' })

-- move selected line(s)
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move selected line(s) downwards' })
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move selected line(s) upwards' })

-- paste mode
vim.keymap.set('n', '<F2>', ':set invpaste paste?<CR>', { desc = 'Toggle paste mode' })
vim.opt.pastetoggle = '<F2>'

-- misc
vim.keymap.set('n', '<leader>a', ':cclose<CR>:lclose<CR>', { desc = 'Dismiss loclist and quickfix' })
vim.keymap.set('n', '<leader>t', 'gg=G``', { desc = 'Indent current file top to bottom' })
vim.keymap.set('n', 'J', 'mzJ`z', { desc = 'Join lines keeping cursor at original place' })
vim.keymap.set('v', '<C-r>', '"hy:%s/<C-r>h//g<left><left>', { desc = 'Replace all occurences of selected text in visual mode' })
