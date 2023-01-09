return {
  'airblade/vim-gitgutter',
  event = 'BufEnter',

  config = function()
    vim.opt.signcolumn = 'yes'
    vim.cmd([[ autocmd BufWritePost * GitGutter ]])
  end,
}
