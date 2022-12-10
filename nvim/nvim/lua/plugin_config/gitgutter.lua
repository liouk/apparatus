vim.opt.signcolumn = 'yes'
vim.cmd([[
  autocmd BufWritePost * GitGutter
]])
