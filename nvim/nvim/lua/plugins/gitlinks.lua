return {
  'liouk/gitlinks.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  event = 'VeryLazy',
  cmd = { 'GitlinkFileOpen', 'GitlinkFileCopy', 'GitlinkBlameOpen', 'GitlinkBlameCopy' },
  keys = {
    { '<leader>gf', mode = { 'n', 'v' }, },
    { '<leader>gc', mode = { 'n', 'v' }, },
    { '<leader>gb', mode = { 'n', 'v' }, },
    { '<leader>gv', mode = { 'n', 'v' }, },
  },

  config = function()
    require('gitlinks').setup()

    vim.keymap.set({'n', 'v'}, '<leader>gf', ':GitlinkFileOpen<CR>')
    vim.keymap.set({'n', 'v'}, '<leader>gc', ':GitlinkFileCopy<CR>')
    vim.keymap.set({'n', 'v'}, '<leader>gb', ':GitlinkBlameOpen<CR>')
    vim.keymap.set({'n', 'v'}, '<leader>gv', ':GitlinkBlameCopy<CR>')
  end,
}
