return {
  'sindrets/diffview.nvim',
  enabled = vim.g.nvim_ide or false,
  dependencies = { 'nvim-lua/plenary.nvim' },
  event = 'VeryLazy',

  config = function()
    require('diffview').setup()
  end
}
