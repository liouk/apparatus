return {
  'lewis6991/gitsigns.nvim',
  event = 'BufReadPre',

  config = function()
    require('gitsigns').setup({
      signs = {
        add          = { text = '│' },
        change       = { text = '│' },
        delete       = { text = '_' },
        topdelete    = { text = '‾' },
        changedelete = { text = '~' },
        untracked    = { text = '│' },
      },
      current_line_blame = false,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'right_align', -- 'eol' | 'overlay' | 'right_align'
        delay = 0,
        ignore_whitespace = false,
      },
      current_line_blame_formatter = '<abbrev_sha> <author>, <author_time:%Y-%m-%d> - <summary>',
    })

    vim.keymap.set('n', '<leader>mb', ':Gitsigns toggle_current_line_blame<CR>', { desc = 'Show current line gitblame [gitsigns]' })
  end,
}
