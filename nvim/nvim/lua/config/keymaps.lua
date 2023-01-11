-- vim. live it.
vim.keymap.set('', '<up>', '<nop>')
vim.keymap.set('', '<down>', '<nop>')
vim.keymap.set('', '<left>', '<nop>')
vim.keymap.set('', '<right>', '<nop>')
vim.keymap.set('i', '<up>', '<nop>')
vim.keymap.set('i', '<down>', '<nop>')
vim.keymap.set('i', '<left>', '<nop>')
vim.keymap.set('i', '<right>', '<nop>')

-- highlight all occurences of current word without moving
vim.keymap.set('n', '<C-b>', '*``')

-- splits
vim.keymap.set('n', '<C-e>', ':vsplit<CR>')
vim.keymap.set('n', '<C-l>', ':wincmd l<CR>')
vim.keymap.set('n', '<C-h>', ':wincmd h<CR>')
vim.keymap.set('i', '<C-s>', '<Esc>:vsplit<CR>i')
vim.keymap.set('i', '<C-l>', '<Esc>:wincmd l<CR>i')
vim.keymap.set('i', '<C-h>', '<Esc>:wincmd h<CR>i')

-- dismiss popup windows
vim.keymap.set('n', '<leader>a', ':cclose<CR>:lclose<CR>')

-- copy to clipboard
vim.keymap.set('v', '<leader>y', '"+y')
vim.keymap.set('n', '<leader>y', '"+y')

-- indent file
vim.keymap.set('n', '<leader>t', 'gg=G``')

-- stay in the middle of the screen when moving/searching
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', 'n', 'nzz')
vim.keymap.set('n', 'N', 'Nzz')

-- replace all occurences of selected text in visual mode
vim.keymap.set('v', '<C-r>', '"hy:%s/<C-r>h//g<left><left>')

-- move selected line(s)
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")

-- cursor stays in place when joining lines with J
vim.keymap.set('n', 'J', 'mzJ`z')

-- paste mode
vim.keymap.set('n', '<F2>', ':set invpaste paste?<CR>')
vim.opt.pastetoggle = '<F2>'
