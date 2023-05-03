return {
  'romgrk/barbar.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  event = 'BufEnter',

  config = function()
    require('bufferline').setup({
      animation = false,
      auto_hide = false,
      tabpages = false,
      clickable = false,
      icons = {
        button = '',
        buffer_index = true,
        filetype = { enabled = false },
        modified = { button = '' },
      },
      maximum_padding = 1,
      minimum_padding = 1,
    })

    vim.keymap.set('n', '<C-j>', ':BufferNext<CR>')
    vim.keymap.set('n', '<C-k>', ':BufferPrevious<CR>')
    vim.keymap.set('i', '<C-j>', '<Esc>:BufferNext<CR>i')
    vim.keymap.set('i', '<C-k>', '<Esc>:BufferPrevious<CR>i')
    vim.keymap.set('n', '<C-w>', ':BufferClose<CR>')
    vim.keymap.set('i', '<C-w>', '<Esc>:BufferClose<CR>')
    vim.keymap.set('n', '<leader>1', ':BufferGoto 1<CR>')
    vim.keymap.set('n', '<leader>2', ':BufferGoto 2<CR>')
    vim.keymap.set('n', '<leader>3', ':BufferGoto 3<CR>')
    vim.keymap.set('n', '<leader>4', ':BufferGoto 4<CR>')
    vim.keymap.set('n', '<leader>5', ':BufferGoto 5<CR>')
    vim.keymap.set('n', '<leader>6', ':BufferGoto 6<CR>')
    vim.keymap.set('n', '<leader>7', ':BufferGoto 7<CR>')
    vim.keymap.set('n', '<leader>8', ':BufferGoto 8<CR>')
    vim.keymap.set('n', '<leader>9', ':BufferGoto 9<CR>')
    vim.keymap.set('n', '<leader>0', ':BufferLast<CR>')
    vim.keymap.set('n', '<leader>v', ':BufferPick<CR>')
  end,
}
