return {
  'm4xshen/smartcolumn.nvim',
  event = 'BufReadPre',

  config = function()
    require('smartcolumn').setup({
      colorcolumn = 80,
      disabled_filetypes = {},
      limit_to_window = true,
    })
  end
}
