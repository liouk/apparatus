return {
  'karb94/neoscroll.nvim',
  keys = {
    '<C-u>',
    '<C-d>',
    '<C-b>',
    '<C-f>',
    '<C-y>',
    '<C-e>',
    'zt',
    'zz',
    'zb',
  },
  config = function()
    require('neoscroll').setup()

    local t = {}
    t['<C-u>'] = {'scroll', {'-vim.wo.scroll', 'true', '50'}}
    t['<C-d>'] = {'scroll', { 'vim.wo.scroll', 'true', '50'}}
    t['<C-b>'] = {'scroll', {'-vim.api.nvim_win_get_height(0)', 'true', '50'}}
    t['<C-f>'] = {'scroll', { 'vim.api.nvim_win_get_height(0)', 'true', '50'}}
    t['<C-y>'] = {'scroll', {'-0.10', 'false', '50'}}
    t['<C-e>'] = {'scroll', { '0.10', 'false', '50'}}
    t['zt']    = {'zt', {'50'}}
    t['zz']    = {'zz', {'50'}}
    t['zb']    = {'zb', {'50'}}

    require('neoscroll.config').set_mappings(t)
  end,
}
