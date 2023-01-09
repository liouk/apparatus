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

return {
  'junegunn/fzf.vim',
  lazy = false,
  dependencies = { 'junegunn/fzf' },

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
  end,
}
