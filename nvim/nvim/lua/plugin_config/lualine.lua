require('lualine').setup({
  options = {
    theme = 'gruvbox',
    disabled_filetypes = { 'packer', 'NvimTree' },
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {{'branch', icon = ''} , 'diff', 'diagnostics'},
    lualine_c = {'filename'},
    lualine_x = {'encoding', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
})
