-- Rg command with preview window
-- source: https://github.com/junegunn/fzf.vim#example-rg-command-with-preview-window
local function vim_grep(qargs, bang)
  local query = '""'
  if qargs ~= nil then
    query = vim.fn.shellescape(qargs)
  end

  local sh = 'rg --column --line-number --no-heading --color=always --smart-case -- ' .. query
  vim.call('fzf#vim#grep', sh, 1, vim.call('fzf#vim#with_preview', 'up:40%', 'ctrl-/'), bang)
end

return {
  'junegunn/fzf.vim',
  dependencies = { 'junegunn/fzf' },
  keys = { '<C-p>', '<leader>f', '<leader>e', '<leader>r' },

  config = function()
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
        height= 0.7,
        highlight= 'Comment',
        border= 'rounded',
      }
    }

    -- keymaps
    vim.keymap.set('n', '<C-p>', ':Files<CR>')
    vim.keymap.set('n', '<leader>f', ':Rg<CR>')
    vim.keymap.set('n', '<leader>e', ':Buffers<CR>')
    vim.keymap.set('n', '<leader>r', ':History<CR>')
  end,
}
