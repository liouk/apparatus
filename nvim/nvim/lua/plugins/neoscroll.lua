return {
  'karb94/neoscroll.nvim',
  keys = {
    '<C-u>',
    '<C-d>',
    '<C-b>',
    '<C-f>',
    'zt',
    'zz',
    'zb',
  },
  config = function()
    require('neoscroll').setup({
      mappings = {},
    })

    local t = {}
    t['<C-u>'] = {'scroll', {'-vim.wo.scroll', 'true', '50'}}
    t['<C-d>'] = {'scroll', { 'vim.wo.scroll', 'true', '50'}}
    t['<C-b>'] = {'scroll', {'-vim.api.nvim_win_get_height(0)', 'true', '50'}}
    t['<C-f>'] = {'scroll', { 'vim.api.nvim_win_get_height(0)', 'true', '50'}}
    t['zt']    = {'zt', {'50'}}
    t['zz']    = {'zz', {'50'}}
    t['zb']    = {'zb', {'50'}}

    require('neoscroll.config').set_mappings(t)
  end,
}
