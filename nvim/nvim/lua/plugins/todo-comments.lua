return {
  'folke/todo-comments.nvim',
  dependencies = { 'nvim-lua/plenary.nvim', 'folke/trouble.nvim' },
  event = 'BufReadPre',

  config = function()
    require('todo-comments').setup({
      signs = false,
      merge_keywords = false,
      keywords = {
        -- TODO: here's a todo comment
        TODO = { icon = '', color = 'warning' },

        -- FIXME: here's a fixme comment
        FIXME = { icon = '', color = 'error' },

        -- NOTE: here's a note comment
        NOTE = { icon = '', color = 'hint' }
      },
      gui_style = {
        fg = 'NONE',
        bg = 'BOLD',
      },
      highlight = {
        multiline = false,
        pattern = [[.*<(KEYWORDS)\s*:]],
        comments_only = true,
        keyword = 'wide',
      },
      pattern = [[\b(KEYWORDS):]],
    })

    vim.keymap.set('n', '<leader>mt', ':TodoTrouble<CR>')
  end,
}
