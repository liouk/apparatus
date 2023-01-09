return {
  'romgrk/barbar.nvim',
  dependencies = { 'kyazdani42/nvim-web-devicons' },

  config = function()
    require('bufferline').setup({
      animation = false,
      auto_hide = false,
      tabpages = false,
      closable = false,
      clickable = false,
      icons = 'numbers',
      maximum_padding = 1,
      minimum_padding = 1,
    })

    vim.keymap.set('n', '<C-j>', '<Cmd>BufferNext<CR>')
    vim.keymap.set('n', '<C-k>', '<Cmd>BufferPrevious<CR>')
    vim.keymap.set('i', '<C-j>', '<Esc><Cmd>BufferNext<CR>i')
    vim.keymap.set('i', '<C-k>', '<Esc><Cmd>BufferPrevious<CR>i')
    vim.keymap.set('n', '<C-w>', '<Cmd>BufferClose<CR>')
    vim.keymap.set('i', '<C-w>', '<Esc><Cmd>BufferClose<CR>')
    vim.keymap.set('n', '<leader>1', '<Cmd>BufferGoto 1<CR>')
    vim.keymap.set('n', '<leader>2', '<Cmd>BufferGoto 2<CR>')
    vim.keymap.set('n', '<leader>3', '<Cmd>BufferGoto 3<CR>')
    vim.keymap.set('n', '<leader>4', '<Cmd>BufferGoto 4<CR>')
    vim.keymap.set('n', '<leader>5', '<Cmd>BufferGoto 5<CR>')
    vim.keymap.set('n', '<leader>6', '<Cmd>BufferGoto 6<CR>')
    vim.keymap.set('n', '<leader>7', '<Cmd>BufferGoto 7<CR>')
    vim.keymap.set('n', '<leader>8', '<Cmd>BufferGoto 8<CR>')
    vim.keymap.set('n', '<leader>9', '<Cmd>BufferGoto 9<CR>')
    vim.keymap.set('n', '<leader>0', '<Cmd>BufferLast<CR>')
    vim.keymap.set('n', '<leader>v', '<Cmd>BufferPick<CR>')
  end,
}
