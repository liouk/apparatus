return {
  'tpope/vim-commentary',
  keys = {
    { 'gc', mode = 'n' },
    { '<leader>c', mode = { 'n', 'v' } },
  },

  config = function()
    vim.keymap.set('n', '<leader>c', ':Commentary<CR>', { desc = 'Toggle-comment line' })
    vim.keymap.set('v', '<leader>c', ":'<,'>Commentary<CR>", { desc = 'Toggle-comment visual selection' })
  end,
}
