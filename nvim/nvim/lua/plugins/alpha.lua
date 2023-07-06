local function alpha_config()
  local Job = require('plenary.job')

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
  mru_files.val[2] = { type = 'padding', val = 0 }
  mru_files.val[3] = {
    type = 'group',
    val = function()
      return { theta.mru(0, cwd, 5) }
    end,
    opts = { shrink_margin = false },
  }

  -- quick links
  local quick_links = {
    type = 'group',
    position = 'center',
    val = {
      { type = 'text', val = 'Quick links', opts = { hl = 'SpecialComment', position = 'center' } },
      dashboard.button('e', '  new buffer',     ':enew <BAR> startinsert <CR>'),
      dashboard.button('s', '  sessions',       ':LoadSession<CR>'),
      dashboard.button('z', '  manage plugins', ':Lazy<CR>'),
      dashboard.button('q', '  quit',           ':qa<CR>'),
    },
  }

  -- recent sessions
  local list_sessions = function()
    local sessions = {}
    local output
    Job:new({
      command = 'ls',
      args = {'-at1'},
      on_exit = function(j)
        output = j:result()
      end,
    }):sync()
    for i = 1, #output do
      if (output[i] ~= '.' and output[i] ~= '..') then
        table.insert(sessions, output[i])
      end
    end
    return sessions
  end
  local sessions = list_sessions()

  local mru_sessions = {
    type = 'group',
    position = 'center',
    val = {
      { type = 'text', val = 'Recent sessions', opts = { hl = 'SpecialComment', position = 'center' } },
    },
  }

  local offset = #mru_sessions.val
  local mru_sessions_shortcuts = {'j', 'k', 'l'}
  for i = 1, (#sessions <= 3 and #sessions or 3) do
    local session_name = string.gsub(sessions[i], vim.g.sessions_path..'/', '')
    mru_sessions.val[offset+i] = dashboard.button(
      mru_sessions_shortcuts[i],
      ' ' .. session_name,
      ':source ' .. sessions[i] .. '<CR>'
    )
  end

  -- footer
  local v = vim.version()
  local plugins_stats = {
    type = 'text',
    val = ' ',
    opts = {
      hl = 'Comment',
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
    { type = 'text', val = header[5], opts = { shrink_margin = false, position = 'center' } },
    { type = 'text', val = header[6], opts = { hl = 'String',  shrink_margin = false, position = 'center' } },
    { type = 'text', val = header[7], opts = { hl = 'String',  shrink_margin = false, position = 'center' } },
    { type = 'text', val = header[8], opts = { hl = 'String',  shrink_margin = false, position = 'center' } },

    -- recent files
    { type = 'padding', val = 2 },
    mru_files,

    -- quick links
    { type = 'padding', val = 1 },
    quick_links,

    { type = 'padding', val = 1 },
    mru_sessions,

    -- footer
    { type = 'padding', val = 2 },
    { type = 'text', val = ' nvim v'..v.major..'.'..v.minor..'.'..v.patch, opts = { hl = 'Comment', shrink_margin = false, position = 'center', } },
    plugins_stats,
    { type = 'text', val = ' '..vim.fn.fnamemodify(cwd, ':~'), opts = { position = 'center', hl = 'Comment', } },
  }

  -- update startup time when completed
  vim.api.nvim_create_autocmd('User', {
    pattern = 'LazyVimStarted',
    callback = function()
      -- the plugins section of the footer
      local stats = require('lazy').stats()
      local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
      plugins_stats.val = ' '..stats.count..' plugins (loaded '..stats.loaded..' in '..ms..'ms)'
      pcall(vim.cmd.AlphaRedraw)
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
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-tree/nvim-web-devicons' },
    event = 'VimEnter',
    config = alpha_config,
  }
}
