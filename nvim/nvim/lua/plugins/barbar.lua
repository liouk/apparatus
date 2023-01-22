return {
  'romgrk/barbar.nvim',
  dependencies = { 'kyazdani42/nvim-web-devicons' },
  event = 'BufEnter',

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

    vim.keymap.set('n', '<C-j>', ':BufferNext<CR>', { desc = 'Switch to next buffer [barbar]' })
    vim.keymap.set('n', '<C-k>', ':BufferPrevious<CR>', { desc = 'Switch to previous buffer [barbar]' })
    vim.keymap.set('i', '<C-j>', '<Esc>:BufferNext<CR>i', { desc = 'Switch to next buffer [barbar]' })
    vim.keymap.set('i', '<C-k>', '<Esc>:BufferPrevious<CR>i', { desc = 'Switch to previous buffer [barbar]' })
    vim.keymap.set('n', '<C-w>', ':BufferClose<CR>', { desc = 'Close buffer [barbar]' })
    vim.keymap.set('i', '<C-w>', '<Esc>:BufferClose<CR>', { desc = 'Close buffer [barbar]' })
    vim.keymap.set('n', '<leader>1', ':BufferGoto 1<CR>', { desc = 'Go to buffer #1 in the tab list [barbar]' })
    vim.keymap.set('n', '<leader>2', ':BufferGoto 2<CR>', { desc = 'Go to buffer #2 in the tab list [barbar]' })
    vim.keymap.set('n', '<leader>3', ':BufferGoto 3<CR>', { desc = 'Go to buffer #3 in the tab list [barbar]' })
    vim.keymap.set('n', '<leader>4', ':BufferGoto 4<CR>', { desc = 'Go to buffer #4 in the tab list [barbar]' })
    vim.keymap.set('n', '<leader>5', ':BufferGoto 5<CR>', { desc = 'Go to buffer #5 in the tab list [barbar]' })
    vim.keymap.set('n', '<leader>6', ':BufferGoto 6<CR>', { desc = 'Go to buffer #6 in the tab list [barbar]' })
    vim.keymap.set('n', '<leader>7', ':BufferGoto 7<CR>', { desc = 'Go to buffer #7 in the tab list [barbar]' })
    vim.keymap.set('n', '<leader>8', ':BufferGoto 8<CR>', { desc = 'Go to buffer #8 in the tab list [barbar]' })
    vim.keymap.set('n', '<leader>9', ':BufferGoto 9<CR>', { desc = 'Go to buffer #9 in the tab list [barbar]' })
    vim.keymap.set('n', '<leader>0', ':BufferLast<CR>', { desc = 'Go to the last buffer in the tab list [barbar]' })
    vim.keymap.set('n', '<leader>v', ':BufferPick<CR>', { desc = 'Quick pick buffer in the tab list [barbar]' })
  end,
}
