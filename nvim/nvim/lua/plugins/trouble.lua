return {
  'folke/trouble.nvim',
  cmd = { 'Trouble', 'TroubleToggle' },
  keys = {
    '<leader>md',
    '<leader>mw',
    'gr',
  },
  dependencies = { 'kyazdani42/nvim-web-devicons' },
  config = function()
    require('trouble').setup({
      icons = false,
      indent_lines = false,
      fold_open = "",
      fold_closed = "",
      padding = false,
      auto_preview = false,
      use_diagnostic_signs = false,
      action_keys = {
        close = "q",
        cancel = "<esc>",
        refresh = "r",
        jump = {"<cr>", "<tab>"},
        open_split = { "<c-x>" },
        open_vsplit = { "<c-v>" },
        open_tab = { "<c-t>" },
        jump_close = {"o"},
        toggle_mode = "m",
        toggle_preview = "P",
        hover = "K",
        preview = "p",
        close_folds = {"zM", "zm"},
        open_folds = {"zR", "zr"},
        toggle_fold = {"zA", "za"},
        previous = "k",
        next = "j"
      },
      signs = {
        error = 'E',
        warning = 'W',
        hint = 'H',
        information = 'I',
      },
    })

    vim.keymap.set('n', '<leader>md', ':Trouble document_diagnostics<cr>')
    vim.keymap.set('n', '<leader>mw', ':Trouble workspace_diagnostics<cr>')
    vim.keymap.set('n', '<leader>ma', ':Trouble<cr>')
    vim.keymap.set('n', 'gr', ':Trouble lsp_references<cr>')
    vim.keymap.set('n', '<leader>a', ':cclose<CR>:lclose<CR>:TroubleClose<CR>')
  end
}
