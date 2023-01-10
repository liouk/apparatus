return {
  'catppuccin/nvim',
  name = 'catppuccin',
  lazy = false,
  priority = 1000,

  config = function()
    require('catppuccin').setup({
      flavour = "macchiato",
      styles = {
        comments = { "italic" },
        conditionals = {},
      },
    })

    vim.cmd.colorscheme "catppuccin"
  end,
}
