local Utils = require('user.utils')
local Gitutils = require('user.gitutils')
local Path = require('plenary.path')
local tag = 'sessions'

local function cwd_basename()
  local fp = vim.api.nvim_buf_get_name(0)
  local cwd = tostring(Path:new(fp):parent())
  local parts = vim.split(cwd, '/', true)
  return parts[#parts]
end

local function get_session_name()
  local name = Gitutils.git_repo_name()
  if name == '' or name == nil then
    name = cwd_basename()
  end
  return name
end

local function save_session(args)
  local sessions_path = vim.g.sessions_path
  vim.fn.mkdir(sessions_path, 'p')

  local filename = ''
  local ext = '.vim'
  if args.args ~= '' then
    filename = tostring(Path:new(sessions_path, args.args))
    if Utils.endswith(filename, ext) then
      ext = ''
    end
  else
    local session_name = get_session_name()
    if session_name == '' then
      Utils.err('no file open in current buffer', tag)
      return
    end
    filename = tostring(Path:new(sessions_path, session_name))
  end

  filename = filename..ext
  vim.api.nvim_command('mksession! ' .. filename)
  Utils.inf('session saved in '..filename, tag)
end

local function load_session()
  -- load fzf.vim as it is a dependency
  vim.api.nvim_command('Lazy load fzf.vim')
  vim.cmd[[
  call fzf#vim#files('~/.local/share/nvim/sessions', {'sink': 'source', 'options': ['--prompt', 'Open Session> ']})
  ]]
end

local function delete_session()
  -- load fzf.vim as it is a dependency
  vim.api.nvim_command('Lazy load fzf.vim')
  vim.cmd[[
  call fzf#vim#files('~/.local/share/nvim/sessions', {'sink': '!rm', 'options': ['--prompt', 'Delete Session> ']})
  ]]
end

vim.api.nvim_create_user_command('SaveSession', save_session, {force = true, nargs = '?'})
vim.api.nvim_create_user_command('LoadSession', load_session, {force = true})
vim.api.nvim_create_user_command('DeleteSession', delete_session, {force = true})

vim.keymap.set('n', '<leader>ss', ':SaveSession<CR>')
vim.keymap.set('n', '<leader>sl', ':LoadSession<CR>')
vim.keymap.set('n', '<leader>sd', ':DeleteSession<CR>')
