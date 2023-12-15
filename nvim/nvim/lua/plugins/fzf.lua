-- Rg command with preview window
-- source: https://github.com/junegunn/fzf.vim#example-rg-command-with-preview-window
local function vim_grep(args, bang)
  local query = ''
  if args ~= nil then
    query = vim.fn.shellescape(args)
  end

  local sh = 'rg --glob "!vendor/" --column --line-number --no-heading --color=always --smart-case -- ' .. query
  local spec = {options = '--delimiter=: --nth=4..'}
  vim.call('fzf#vim#grep', sh, 1, vim.call('fzf#vim#with_preview', spec, 'up:40%'), bang)
end

return {
  'junegunn/fzf.vim',
  dependencies = { 'junegunn/fzf' },
  event = 'VeryLazy',

  config = function()
    vim.api.nvim_create_user_command('Rg', function(c)
      vim_grep(c.args, c.bang)
    end, { bang = true, nargs = '*' })

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
    vim.keymap.set('n', '<leader>h', ':History<CR>')
  end,
}
