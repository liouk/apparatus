return {
  'folke/which-key.nvim',
  event = 'VeryLazy',

  config = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 500
    vim.keymap.set('n', '<leader>,', ":WhichKey<CR>")

    local wk = require('which-key')
    wk.setup({})
    wk.add({
      { '<leader>g', group = 'git' },
      { '<leader>m', group = 'Trouble' },
      { '<leader>s', group = 'sessions' },
      { 'g', group = 'Movements/LSP' },
    })
  end,
}
