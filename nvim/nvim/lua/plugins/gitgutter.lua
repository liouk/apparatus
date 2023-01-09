return {
  'airblade/vim-gitgutter',

  config = function()
    vim.opt.signcolumn = 'yes'
    vim.cmd([[ autocmd BufWritePost * GitGutter ]])
  end,
}
