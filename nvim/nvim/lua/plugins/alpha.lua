local function alpha_config()
  local Job = require('plenary.job')

  local dashboard = require('alpha.themes.dashboard')
  local theta = require('alpha.themes.theta')
  local config = theta.config
  local cwd = vim.fn.getcwd()
  local header = {
    '             `.-..........`             ',
    '            `////////::.`-/.            ',
    '            -: ....-////////.           ',
    '            //:-::///////////`          ',
    '     `--::: `-://////////////:          ',
    '     //////-    ``.-:///////// .`       ',
    '     `://////:-.`    :///////::///:`    ',
    '       .-/////////:---/////////////:    ',
    '          .-://////////////////////.    ',
    '         yMN+`.-::///////////////-`     ',
    '      .-`:NMMNMs`  `..-------..`        ',
    '       MN+/mMMMMMhoooyysshsss           ',
    'MMM    MMMMMMMMMMMMMMyyddMMM+           ',
    ' MMMM   MMMMMMMMMMMMMNdyNMMh`     hyhMMM',
    '  MMMMMMMMMMMMMMMMyoNNNMMM+.   MMMMMMMM ',
    '   MMNMMMNNMMMMMNM+ mhsMNyyyyMNMMMMsMM  ',
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
  local header_opts_red = { hl = 'Error',  shrink_margin = false, position = 'center' }
  local header_opts_white = { hl = 'Variable',  shrink_margin = false, position = 'center' }
  -- local header_cmd = "sh " .. os.getenv("HOME") .. "/.config/nvim/lua/plugins/alpha-logo.sh"
  config.layout = {
    -- header
    -- { type = "terminal", command = header_cmd, width = 80, height = 28, opts = { redraw = true } },
    { type = 'padding', val = 1 },
    { type = 'text', val = header[1], opts = header_opts_red },
    { type = 'text', val = header[2], opts = header_opts_red },
    { type = 'text', val = header[3], opts = header_opts_red },
    { type = 'text', val = header[4], opts = header_opts_red },
    { type = 'text', val = header[5], opts = header_opts_red },
    { type = 'text', val = header[6], opts = header_opts_red },
    { type = 'text', val = header[7], opts = header_opts_red },
    { type = 'text', val = header[8], opts = header_opts_red },
    { type = 'text', val = header[9], opts = header_opts_red },
    { type = 'text', val = header[10], opts = header_opts_red },
    { type = 'text', val = header[11], opts = header_opts_white },
    { type = 'text', val = header[12], opts = header_opts_white },
    { type = 'text', val = header[13], opts = header_opts_white },
    { type = 'text', val = header[14], opts = header_opts_white },
    { type = 'text', val = header[15], opts = header_opts_white },
    { type = 'text', val = header[16], opts = header_opts_white },

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
