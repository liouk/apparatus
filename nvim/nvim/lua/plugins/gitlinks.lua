return {
  'liouk/gitlinks.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  cmd = { 'GitlinkFileOpen', 'GitlinkFileCopy', 'GitlinkBlameOpen', 'GitlinkBlameCopy' },
  keys = { '<leader>gf', '<leader>gc', '<leader>gb', '<leader>gv' },

  config = function()
    require('gitlinks').setup()

    vim.keymap.set({'n', 'v'}, '<leader>gf', ':GitlinkFileOpen<CR>')
    vim.keymap.set({'n', 'v'}, '<leader>gc', ':GitlinkFileCopy<CR>')
    vim.keymap.set({'n', 'v'}, '<leader>gb', ':GitlinkBlameOpen<CR>')
    vim.keymap.set({'n', 'v'}, '<leader>gv', ':GitlinkBlameCopy<CR>')
  end,
}
