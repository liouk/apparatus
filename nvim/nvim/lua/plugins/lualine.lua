return {
  'nvim-lualine/lualine.nvim',
  lazy = false,
  dependencies = { 'kyazdani42/nvim-web-devicons' },

  config = function()
    require('lualine').setup({
      options = {
        theme = 'catppuccin',
        disabled_filetypes = { 'packer', 'NvimTree' },
      },
      sections = {
        lualine_a = {'mode'},
        lualine_b = {{'branch', icon = ''} , 'diff', 'diagnostics'},
        lualine_c = {{'filename', path = 1}},
        lualine_x = {'encoding', 'filetype'},
        lualine_y = {'progress'},
        lualine_z = {'location'}
      },
    })
  end,
}
