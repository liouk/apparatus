return {
  'nvim-tree/nvim-tree.lua',
  dependencies = { 'kyazdani42/nvim-web-devicons' },
  keys = { '<leader>d' },

  config = function()
    require('nvim-tree').setup({
      view = {
        adaptive_size = true,
      },
    })
    vim.keymap.set('n', '<leader>d', ':NvimTreeToggle<CR>')
  end,
}
