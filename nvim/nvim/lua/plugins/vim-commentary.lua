return {
  'tpope/vim-commentary',
  event = 'VeryLazy',

  config = function()
    vim.keymap.set('n', '<leader>c', ':Commentary<CR>')
    vim.keymap.set('v', '<leader>c', ":'<,'>Commentary<CR>")
  end,
}
