return {
  'folke/which-key.nvim',
  event = 'BufEnter',

  config = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 500
    vim.keymap.set('n', '<leader>,', ":WhichKey<CR>")

    local wk = require('which-key')
    wk.setup({})
    wk.register({
      ['<leader>'] = {
        g = { name = 'git' },
        m = { name = 'Trouble' },
        s = { name = 'sessions' },
      },
      g = { name = 'Movements/LSP'},
    })
  end,
}
