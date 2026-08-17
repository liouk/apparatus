-- go uses tabs, so don't expand them to spaces
vim.opt.expandtab = false

if vim.g.nvim_ide then
  vim.keymap.set('n', '<leader>t', ':GoImport<CR>', { buffer = true })
  vim.keymap.set('n', '<leader>r', ':GoRename<CR>', { buffer = true })
end
