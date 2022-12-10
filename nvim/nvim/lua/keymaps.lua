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

-- splits
vim.keymap.set("n", "<C-e>", ":vsplit<CR>")
vim.keymap.set("n", "<C-l>", ":wincmd l<CR>")
vim.keymap.set("n", "<C-h>", ":wincmd h<CR>")
vim.keymap.set("i", "<C-s>", "<Esc>:vsplit<CR>i")
vim.keymap.set("i", "<C-l>", "<Esc>:wincmd l<CR>i")
vim.keymap.set("i", "<C-h>", "<Esc>:wincmd h<CR>i")

-- dismiss popup windows
vim.keymap.set("n", "<leader>a", ":cclose<CR>:lclose<CR>")

-- copy to clipboard
vim.keymap.set("v", "<leader>y", '"*y')
vim.keymap.set("n", "<leader>y", '"*y')

-- bring search result to mid screen
vim.keymap.set("n", "n", "nzz")
vim.keymap.set("n", "N", "Nzz")

-- auto-complete brackets
vim.keymap.set("i", "{<CR>", "{<CR>}<Esc>O")
vim.keymap.set("i", "{{", "{")
vim.keymap.set("i", "{}", "{}")

-- replace all occurences of selected text in visual mode
vim.keymap.set("v", "<C-r>", '"hy:%s/<C-r>h//g<left><left>')

-- paste mode
vim.keymap.set("n", "<F2>", ":set invpaste paste?<CR>")
vim.opt.pastetoggle = "<F2>"
