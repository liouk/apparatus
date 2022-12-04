-- vim. live it.
vim.keymap.set("", "<up>", "<nop>")
vim.keymap.set("", "<down>", "<nop>")
vim.keymap.set("", "<left>", "<nop>")
vim.keymap.set("", "<right>", "<nop>")
vim.keymap.set("i", "<up>", "<nop>")
vim.keymap.set("i", "<down>", "<nop>")
vim.keymap.set("i", "<left>", "<nop>")
vim.keymap.set("i", "<right>", "<nop>")
vim.keymap.set("v", "<up>", "<nop>")
vim.keymap.set("v", "<down>", "<nop>")
vim.keymap.set("v", "<left>", "<nop>")
vim.keymap.set("v", "<right>", "<nop>")

-- highlight all occurences of current word without moving
vim.keymap.set("n", "<C-b>", "*``")

-- buffers
vim.opt.hidden = true
vim.keymap.set("n", "<C-j>", ":bnext<CR>")
vim.keymap.set("n", "<C-k>", ":bprevious<CR>")
vim.keymap.set("n", "<C-o>", ":edit ")
vim.keymap.set("i", "<C-j>", "<Esc>:bnext<CR>i")
vim.keymap.set("i", "<C-k>", "<Esc>:bprevious<CR>i")
vim.keymap.set("i", "<C-e>", "<Esc>:edit ")

-- vim-buffkill
vim.keymap.set("n", "<C-w>", ":BW<CR>")
vim.keymap.set("i", "<C-w>", "<Esc>:BW<CR>")

-- splits
vim.keymap.set("n", "<C-e>", ":vsplit<CR>")
vim.keymap.set("n", "<C-l>", ":wincmd l<CR>")
vim.keymap.set("n", "<C-h>", ":wincmd h<CR>")
vim.keymap.set("i", "<C-s>", "<Esc>:vsplit<CR>i")
vim.keymap.set("i", "<C-l>", "<Esc>:wincmd l<CR>i")
vim.keymap.set("i", "<C-h>", "<Esc>:wincmd h<CR>i")
