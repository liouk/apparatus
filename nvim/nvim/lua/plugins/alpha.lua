local function alpha_config()
  local Job = require('plenary.job')

  local dashboard = require('alpha.themes.dashboard')
  local theta = require('alpha.themes.theta')
  local config = theta.config
  local cwd = vim.fn.getcwd()

  -- header
  local header = {
    [[                                                                     ]],
    [[       ████ ██████           █████      ██                     ]],
    [[      ███████████             █████                             ]],
    [[      █████████ ███████████████████ ███   ███████████   ]],
    [[     █████████  ███    █████████████ █████ ██████████████   ]],
    [[    █████████ ██████████ █████████ █████ █████ ████ █████   ]],
    [[  ███████████ ███    ███ █████████ █████ █████ ████ █████  ]],
    [[ ██████  █████████████████████ ████ █████ █████ ████ ██████ ]],
  }
  local header_colors = { 'WinSeparator', 'Constant', 'Number', 'Exception', 'String', 'Function', 'Identifier', 'Keyword' }
  math.randomseed(os.time())
  local header_color = header_colors[ math.random(#header_colors) ]
  local header_opts = { hl = header_color, shrink_margin = false, position = 'center' }
  local v = vim.version()
  local nvim_version = 'v'..v.major..'.'..v.minor..'.'..v.patch
  nvim_version = string.format('%70s', nvim_version)

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
      command = '/bin/ls',
      args = {'-atu1', vim.g.sessions_path},
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
    local session_filepath = vim.g.sessions_path..'/'..sessions[i]
    mru_sessions.val[offset+i] = dashboard.button(
      mru_sessions_shortcuts[i],
      ' ' .. sessions[i],
      ':source ' .. session_filepath .. '<CR>'
    )
  end

  -- footer
  local footer_opts = { hl = 'Comment', shrink_margin = false, position = 'center' }
  local plugins_stats = {
    type = 'text',
    val = ' ',
    opts = footer_opts,
  }

  -- set current config
  config.layout = {
    -- header
    { type = 'padding', val = 1 },
    { type = 'text', val = header[1], opts = header_opts },
    { type = 'text', val = header[2], opts = header_opts },
    { type = 'text', val = header[3], opts = header_opts },
    { type = 'text', val = header[4], opts = header_opts },
    { type = 'text', val = header[5], opts = header_opts },
    { type = 'text', val = header[6], opts = header_opts },
    { type = 'text', val = header[7], opts = header_opts },
    { type = 'text', val = header[8], opts = header_opts },
    { type = 'text', val = nvim_version, opts = footer_opts },

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
    plugins_stats,
    { type = 'text', val = '  '..vim.fn.fnamemodify(cwd, ':~'), opts = footer_opts },
  }

  -- update startup time when completed
  vim.api.nvim_create_autocmd('User', {
    pattern = 'LazyVimStarted',
    callback = function()
      -- the plugins section of the footer
      local stats = require('lazy').stats()
      local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
      plugins_stats.val = '  '..stats.count..' plugins (loaded '..stats.loaded..' in '..ms..'ms)'
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
