return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  event = 'VeryLazy',

  config = function()
    require('lualine').setup({
      options = {
        theme = 'auto',
        disabled_filetypes = { 'packer', 'NvimTree' },
        component_separators = { left = '', right = ''},
        section_separators = { left = '', right = ''},
      },
      sections = {
        lualine_a = {'mode'},
        lualine_b = {{'branch', icon = ''} , 'diff', 'diagnostics'},
        lualine_c = {{'filename', path = 1}},
        lualine_x = {'filetype'},
        lualine_y = {'progress'},
        lualine_z = {'location'}
      },
    })
  end,
}
