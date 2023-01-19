local function fn_short(fn)
  local short_fn = vim.fn.fnamemodify(fn, ':~')

  return short_fn
end

local function alpha_config()
  local dashboard = require('alpha.themes.dashboard')
  local theta = require('alpha.themes.theta')
  local config = theta.config
  local cwd = vim.fn.getcwd()

  -- header
  local header = {
    '           9   /   F       J',
    '    l  μ   r   t   =       λ  i  |',
    ' A  4  V   Y   3   T   @   ?  .  _',
    ' y  *  -   $   r   <   ω   8  ?  Q',
    ' .  :  n   e   o      i   m  :  .',
    ' b  ;  {   f   ]   h   X   <  v  k',
    '    o  &   f   d   H       0  θ  E',
    '           D       %          ¢  0',
  }

  -- mru_files
  local mru_files = config.layout[4]
  mru_files.val[3] = {
    type = 'group',
    val = function()
      return { theta.mru(0, cwd, 5) }
    end,
    opts = { shrink_margin = false },
  }

  -- buttons
  local buttons = config.layout[6]
  buttons.val = {
    dashboard.button('e',         '  new buffer',     ':enew <BAR> startinsert <CR>'),
    dashboard.button('<leader>d', '  explore dir'  ),
    dashboard.button('<C-p>',     '  find here'    ),
    dashboard.button('<leader>f', '  grep here'    ),
    dashboard.button('<leader>r', '  search recent'),
    dashboard.button('z',         '  manage plugins', ':Lazy<CR>'),
    dashboard.button('q',         '  quit',           ':qa<CR>'),
  }

  -- footer
  local v = vim.version()
  local plugins_stats = {
    type = 'text',
    val = ' ',
    opts = {
      hl = 'SignColumn',
      shrink_margin = false,
      position = 'center',
    },
  }

  -- set current config
  config.layout = {
    -- header
    { type = 'padding', val = 2 },
    { type = 'text', val = header[1], opts = { hl = 'String',  shrink_margin = false, position = 'center' } },
    { type = 'text', val = header[2], opts = { hl = 'String',  shrink_margin = false, position = 'center' } },
    { type = 'text', val = header[3], opts = { hl = 'String',  shrink_margin = false, position = 'center' } },
    { type = 'text', val = header[4], opts = { hl = 'String',  shrink_margin = false, position = 'center' } },
    { type = 'text', val = header[5], opts = { hl = 'ModeMsg', shrink_margin = false, position = 'center' } },
    { type = 'text', val = header[6], opts = { hl = 'String',  shrink_margin = false, position = 'center' } },
    { type = 'text', val = header[7], opts = { hl = 'String',  shrink_margin = false, position = 'center' } },
    { type = 'text', val = header[8], opts = { hl = 'String',  shrink_margin = false, position = 'center' } },

    -- recent files
    { type = 'padding', val = 2 },
    mru_files,

    -- quick links
    { type = 'padding', val = 1 },
    { type = 'text', val = 'Quick links', opts = { hl = 'SpecialComment', position = 'center' } },
    { type = 'padding', val = 1 },
    buttons,

    -- footer
    { type = 'padding', val = 2 },
    { type = 'text', val = ' nvim v'..v.major..'.'..v.minor..'.'..v.patch, opts = { hl = 'SignColumn', shrink_margin = false, position = 'center', } },
    plugins_stats,
    { type = 'text', val = ' '..fn_short(cwd), opts = { position = 'center', hl = 'SignColumn', } },
  }

  -- update startup time when completed
  vim.api.nvim_create_autocmd('User', {
    pattern = 'LazyVimStarted',
    callback = function()
      -- the plugins section of the footer
      local stats = require('lazy').stats()
      local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
      plugins_stats.val = ' '..stats.count..' plugins (loaded '..stats.loaded..' in '..ms..'ms)'
    end,
  })

  -- disable folding on alpha buffer
  vim.cmd([[
  autocmd FileType alpha setlocal nofoldenable
  ]])

  require('alpha').setup(config)
end

return {
  {
    'goolord/alpha-nvim',
    dependencies = { 'nvim-lua/plenary.nvim', 'kyazdani42/nvim-web-devicons' },
    event = 'VimEnter',
    config = alpha_config,
  }
}
