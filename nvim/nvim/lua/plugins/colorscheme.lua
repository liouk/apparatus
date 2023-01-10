-- command to print highlight group for debugging the colorscheme
-- vim.api.nvim_create_user_command('PrintHighlightGroup',
-- function () print(vim.inspect(vim.treesitter.get_captures_at_cursor(0))) end,
-- {})

return {
  'catppuccin/nvim',
  name = 'catppuccin',
  lazy = false,
  priority = 1000,

  config = function()
    require('catppuccin').setup({
      flavour = 'macchiato',
      styles = {
        comments = { 'italic' },
        conditionals = {},
      },
      custom_highlights = function(colors)
        return {
          ['@parameter'] = { fg = colors.maroon, style = {} },
          ['@namespace'] = { fg = colors.blue, style = {} },
        }
      end,
    })

    vim.cmd.colorscheme 'catppuccin'
  end,
}
