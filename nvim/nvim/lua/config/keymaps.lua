-- vim. live it.
vim.keymap.set('', '<up>', '<nop>')
vim.keymap.set('', '<down>', '<nop>')
vim.keymap.set('', '<left>', '<nop>')
vim.keymap.set('', '<right>', '<nop>')
vim.keymap.set('i', '<up>', '<nop>')
vim.keymap.set('i', '<down>', '<nop>')
vim.keymap.set('i', '<left>', '<nop>')
vim.keymap.set('i', '<right>', '<nop>')

-- splits
vim.keymap.set('n', '<C-e>', ':vsplit<CR>')
vim.keymap.set('n', '<C-h>', ':wincmd w<CR>')
vim.keymap.set('i', '<C-s>', '<Esc>:vsplit<CR>i')
vim.keymap.set('i', '<C-h>', '<Esc>:wincmd w<CR>i')

-- clipboard
vim.keymap.set('v', '<leader>y', '"+y', { desc = 'Copy to clipboard' })
vim.keymap.set('n', '<leader>y', '"+y', { desc = 'Copy to clipboard' })

-- cursor movements
vim.keymap.set('n', '<C-b>', '*``', { desc = 'Highlight word without moving' })
vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Move down; cursor at middle' })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Move up; cursor at middle' })
vim.keymap.set('n', 'n', 'nzz', { desc = 'Search forward; cursor at middle' })
vim.keymap.set('n', 'N', 'Nzz', { desc = 'Search backward; cursor at middle' })

-- move selected line(s)
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move selected lines down' })
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move selected lines up' })

-- paste mode
vim.keymap.set('n', '<F2>', ':set invpaste paste?<CR>', { desc = 'Toggle paste mode' })
vim.opt.pastetoggle = '<F2>'

-- misc
vim.keymap.set('n', '<leader>a', ':cclose<CR>:lclose<CR>', { desc = 'Dismiss loclist and quickfix' })
vim.keymap.set('n', 'J', 'mzJ`z', { desc = 'Join lines (preserve cursor)' })
vim.keymap.set('v', '<C-r>', '"hy:%s/<C-r>h//g<left><left>', { desc = 'Replace visual selection' })
vim.keymap.set('n', '<CR>', 'ciw', { desc = 'Delete word under cursor and insert' })

-- syntax highlighting shortcuts
vim.keymap.set('', '<leader>w1', ':set syn=sh<CR>')
vim.keymap.set('', '<leader>w2', ':set syn=yaml<CR>')
vim.keymap.set('', '<leader>w3', ':set syn=json<CR>')
