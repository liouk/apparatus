return {
  'nvim-tree/nvim-tree.lua',
  enabled = vim.g.nvim_ide or false,
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
