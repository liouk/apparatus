-- command to print highlight group for debugging the colorscheme
-- vim.api.nvim_create_user_command('PrintHighlightGroup', function() print(vim.inspect(vim.treesitter.get_captures_at_cursor(0))) end, {})

return {
  {
    'norcalli/nvim-colorizer.lua',
    lazy = false,
    enabled = false,
  },
  {
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
          loops = {},
          functions = {},
          keywords = {},
          strings = {},
          variables = {},
          numbers = {},
          booleans = {},
          properties = {},
          types = {},
          operators = {},
        },
        integrations = {
          barbar = true,
          leap = true,
          which_key = true,
        },
        custom_highlights = function()
          return {
            -- remove italic from namespace style
            ['@namespace'] = { style = {} },
            ['@function.builtin.bash'] = { style = {} },
          }
        end,
      })
      vim.cmd.colorscheme 'catppuccin-macchiato'
    end
  }
}
