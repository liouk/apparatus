return {
  'nvim-tree/nvim-tree.lua',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  event = 'VeryLazy',

  config = function()
    require('nvim-tree').setup({
      view = {
        adaptive_size = true,
      },
    })
    vim.keymap.set('n', '<leader>d', ':NvimTreeToggle<CR>')
  end,
}
