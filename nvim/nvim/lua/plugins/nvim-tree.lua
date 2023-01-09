return {
  'nvim-tree/nvim-tree.lua',
  dependencies = { 'kyazdani42/nvim-web-devicons' },
  keys = { '<leader>d' },

  config = function()
    require('nvim-tree').setup()
    vim.keymap.set('n', '<leader>d', '<cmd>NvimTreeToggle<CR>')
  end,
}
