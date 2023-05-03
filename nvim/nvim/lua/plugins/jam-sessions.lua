return {
  'liouk/jam-sessions.nvim',
  dependencies = { 'junegunn/fzf', 'junegunn/fzf.vim', 'nvim-lua/plenary.nvim' },
  cmd = { 'SaveSession', 'LoadSession', 'DeleteSession' },
  keys = { '<leader>ss', '<leader>sl',  '<leader>sd', '<leader>sq' },

  config = function()
    require('jam-sessions').setup({
      dir = vim.g.sessions_path
    })

    vim.keymap.set('n', '<leader>ss', ':SaveSession<CR>')
    vim.keymap.set('n', '<leader>sl', ':LoadSession<CR>')
    vim.keymap.set('n', '<leader>sd', ':DeleteSession<CR>')
    vim.keymap.set('n', '<leader>sq', ":exec 'SaveSession' <Bar> qall<CR>")
  end,
}
