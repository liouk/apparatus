-- command to print highlight group for debugging the colorscheme
-- vim.api.nvim_create_user_command('PrintHighlightGroup',
-- function () print(vim.inspect(vim.treesitter.get_captures_at_cursor(0))) end,
-- {})

return {
  'rebelot/kanagawa.nvim',
  name = 'kanagawa',
  lazy = false,
  priority = 1000,

  config = function()
    require('kanagawa').setup({
      undercurl = false,
      keywordStyle = {},
      variablebuiltinStyle = {},
    })

    vim.cmd.colorscheme 'kanagawa'
  end
}
