return {
  'lewis6991/gitsigns.nvim',
  event = 'VeryLazy',

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
        virt_text_pos = 'right_align',
        delay = 0,
        ignore_whitespace = false,
      },
      current_line_blame_formatter = '<abbrev_sha> <author>, <author_time:%Y-%m-%d> - <summary>',
    })

    vim.keymap.set('n', '<leader>gr', ':Gitsigns reset_hunk<CR>')
    vim.keymap.set('n', '<leader>gn', ':Gitsigns next_hunk<CR>')
    vim.keymap.set('n', '<leader>gp', ':Gitsigns prev_hunk<CR>')
    vim.keymap.set('n', '<leader>gs', ':Gitsigns preview_hunk<CR>')
  end,
}
