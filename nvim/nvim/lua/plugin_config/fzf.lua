-- Rg command with preview window
-- source: https://github.com/junegunn/fzf.vim#example-rg-command-with-preview-window
local function vim_grep(qargs, bang)
  local query = '""'
  if qargs ~= nil then
    query = vim.fn.shellescape(qargs)
  end

  local sh = 'rg --column --line-number --no-heading --color=always --smart-case -- ' .. query
  vim.call('fzf#vim#grep', sh, 1, vim.call('fzf#vim#with_preview', 'right:50%', 'ctrl-/'), bang)
end

vim.api.nvim_create_user_command(
  'Rg',
  function(arg)
    vim_grep(arg.qargs, arg.bang)
  end,
  { bang = true, nargs = '*' }
)

vim.g.fzf_preview_window = {}
vim.g.fzf_layout = {
  window= {
    width= 0.7,
    height= 0.5,
    highlight= 'Comment',
    border= 'rounded',
  }
}

-- keymaps
vim.keymap.set('n', '<C-p>', '<cmd>Files<CR>')
vim.keymap.set('n', '<leader>f', '<cmd>Rg<CR>')
vim.keymap.set('n', '<leader>e', '<cmd>Buffers<CR>')
vim.keymap.set('n', '<leader>r', '<cmd>History<CR>')

-- adapt to colorscheme: gruvbox
-- let g:fzf_colors = {}
-- let g:fzf_colors.fg      = ['fg', 'GruvboxFg1']
-- let g:fzf_colors.bg      = [gfg', 'GruvboxBg0']
-- let g:fzf_colors.hl      = ['fg', 'GruvboxRed']
-- let g:fzf_colors['fg+']  = ['fg', 'GruvboxGreen']
-- let g:fzf_colors['bg+']  = ['fg', 'GruvboxBg1']
-- let g:fzf_colors['hl+']  = ['fg', 'GruvboxRed']
-- let g:fzf_colors.info    = ['fg', 'GruvboxOrange']
-- let g:fzf_colors.border  = ['fg', 'GruvboxBg0']
-- let g:fzf_colors.prompt  = ['fg', 'GruvboxAqua']
-- let g:fzf_colors.pointer = ['fg', 'GruvboxOrange']
-- let g:fzf_colors.marker  = ['fg', 'GruvboxYellow']
-- let g:fzf_colors.spinner = ['fg', 'GruvboxGreen']
-- let g:fzf_colors.header  = ['fg', 'GruvboxBlue']
