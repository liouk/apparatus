return {
  'FabijanZulj/blame.nvim',
  event = 'BufEnter',

  config = function()
    require('blame').setup({})

    vim.keymap.set('n', '<leader>b', ':ToggleBlame virtual<CR>')
  end,
}
