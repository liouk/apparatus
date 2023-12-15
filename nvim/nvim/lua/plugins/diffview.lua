return {
  'sindrets/diffview.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  event = 'VeryLazy',

  config = function()
    require('diffview').setup()
  end
}
