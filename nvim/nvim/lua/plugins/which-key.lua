return {
  'folke/which-key.nvim',
  event = 'VeryLazy',

  config = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 500
    vim.keymap.set('n', '<leader>,', ":WhichKey<CR>")

    local wk = require('which-key')
    wk.setup({})
    local groups = {
      ['<leader>g'] = { name = 'git' },
      ['<leader>s'] = { name = 'sessions' },
      ['g'] = { name = 'Movements' },
    }
    if vim.g.nvim_ide then
      groups['<leader>m'] = { name = 'Trouble' }
      groups['g'] = { name = 'Movements/LSP' }
    end
    wk.register(groups)
  end,
}
