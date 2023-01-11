return {
  'airblade/vim-gitgutter',
  event = 'BufEnter',

  config = function()
    vim.g.gitgutter_sign_priority = 0
    vim.g.gitgutter_sign_allow_clobber = 0
    vim.cmd([[ autocmd BufWritePost * GitGutter ]])
  end,
}
