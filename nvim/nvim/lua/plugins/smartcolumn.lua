return {
  'm4xshen/smartcolumn.nvim',
  event = 'VeryLazy',

  config = function()
    require('smartcolumn').setup({
      colorcolumn = 80,
      disabled_filetypes = {"yaml"},
      limit_to_window = true,
    })
  end
}
