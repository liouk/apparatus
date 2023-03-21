--[[ Gitlinks

Copy and Open remote file and blame links directly from neovim. All exposed
commands can be used with or without a visual range; the links will be
generated accordingly. The module will try to not generate or open links for
files/branches/changes that don't exist on the remote, and display an error
instead.

The module requires nvim-lua/plenary.nvim.

Services supported:
  GitHub
  GitLab

Commands:
  :GitlinkFileCopy
  :GitlinkFileOpen
  :GitlinkBlameCopy
  :GitlinkBlameOpen

Inspired by tpope/vim-fugitive and ruifm/gitlinker.nvim ]]--

local G = {}
local Job = require('plenary.job')
local Utils = require('user.utils')
local Git = require('user.gitutils')

local function open_url(url)
  local cmd = vim.fn.has('macunix') == 1 and 'open' or 'xdg-open'
  Job:new({ command = cmd, args = { url } }):start()
end

local function get_linestr(rstart, rend)
  local linestr = ''
  if rstart and rstart > 0 then
    linestr = string.format('#L%d', rstart)
  end
  if rend and rend > rstart then
    linestr = string.format('%s-L%d', linestr, rend)
  end

  return linestr
end

local function copy_url(url)
  vim.api.nvim_command("let @+ = '" .. url .. "'")
  Utils.inf("copied url '" .. url .. "'")
end

function G.git_remote()
  return Git.git({'remote'})[1]
end

function G.git_branch()
  return Git.git({'rev-parse', '--abbrev-ref', 'HEAD'})[1]
end

function G.git_file_untracked()
  return G.i.file.path_full == '' or Git.git({'ls-files', G.i.file.path_full}) == ''
end

function G.git_branch_untracked()
  local res = Git.git({'config', '--get', 'branch.' .. G.i.git.branch .. '.remote'})[1]
  return res == nil or res == ''
end

function G.git_file_exists()
  local _, exitcode = Git.git({'cat-file', '-e', G.i.git.remote..'/'..G.i.git.branch..':'..G.i.file.path_relative})
  return exitcode == 0
end

function G.git_file_dirty()
  local res = Git.git({'status', '-s', G.i.file.path_relative})
  return res[1] ~= nil and res[1] ~= ''
end

function G.git_range_uncommitted()
  local range = G.i.range.vstart .. ',' .. G.i.range.vend
  local output = table.concat(Git.git({'blame', G.i.file.path_full, '-L', range}), '')
  return output:find('Not Committed Yet') ~= nil
end

function G.git_url(linktype)
  local linestr = get_linestr(G.i.range.vstart, G.i.range.vend)

  if G.i.git.remote_url:find('github.com') then
    return string.format('%s/%s/%s/%s%s',
      G.i.git.remote_url,
      linktype,
      G.i.git.branch,
      G.i.file.path_relative,
      linestr)

  elseif G.i.git.remote_url:find('gitlab.com') then
    return string.format('%s/-/%s/%s/%s%s',
      G.i.git.remote_url,
      linktype,
      G.i.git.branch,
      G.i.file.path_relative,
      linestr)
  end

  return ''
end

function G.gitlinks(linktype, action, args)
  -- helper table to be used in module functions to avoid re-running git
  G.i = {
    range = {vstart = 0, vend = 0},
    file = {root = '', path_full = '', path_relative = ''},
    git = {remote = '', remote_url = '', branch = ''}
  }

  if linktype ~= 'blob' and linktype ~= 'blame' then
    Utils.err("unknown linktype '" .. action .. "'")
    return
  end

  if action ~= 'copy' and action ~= 'open' then
    Utils.err("unknown action '" .. action .. "'")
    return
  end

  local remote_url, error = Git.git_remote_url()
  if remote_url == '' then
    Utils.err(error)
    return
  end

  G.i.git.remote_url = remote_url
  G.i.git.remote = G.git_remote()
  G.i.git.branch = G.git_branch()
  G.i.file.path_full = vim.api.nvim_buf_get_name(0)
  G.i.file.root = Git.git_root(G.i.file.path_full) .. '/'
  G.i.file.path_relative = G.i.file.path_full:sub(G.i.file.root:len()+1)
  if args.range > 0 then
    G.i.range.vstart = args.line1
    G.i.range.vend = args.line2
  end

  if G.git_file_untracked() then
    Utils.err('cannot get link; file is untracked')
    return
  end

  if G.git_branch_untracked() then
    Utils.err('cannot get link; branch is untracked')
    return
  end

  if not G.git_file_exists() then
    Utils.err('file does not exist on remote and branch')
    return
  end

  if G.i.range.vstart > 0 and G.i.range.vend > 0 then
    if G.git_range_uncommitted() then
      Utils.err('selected range is uncommitted')
      return
    end

    if G.git_file_dirty() then
      Utils.wrn('file is dirty; selected ranges may be off')
    end
  end

  local url = G.git_url(linktype)
  if action == 'open' then
    open_url(url)
  else
    copy_url(url)
  end
end

local function gitlink_file_copy(args) G.gitlinks('blob', 'copy', args) end
local function gitlink_file_open(args) G.gitlinks('blob', 'open', args) end
local function gitlink_blame_copy(args) G.gitlinks('blame', 'copy', args) end
local function gitlink_blame_open(args) G.gitlinks('blame', 'open', args) end

local cmdopts = {range = true, force = true}
vim.api.nvim_create_user_command('GitlinkFileCopy', gitlink_file_copy, cmdopts)
vim.api.nvim_create_user_command('GitlinkFileOpen', gitlink_file_open, cmdopts)
vim.api.nvim_create_user_command('GitlinkBlameCopy', gitlink_blame_copy, cmdopts)
vim.api.nvim_create_user_command('GitlinkBlameOpen', gitlink_blame_open, cmdopts)

vim.keymap.set({'n', 'v'}, '<leader>gf', ':GitlinkFileOpen<CR>')
vim.keymap.set({'n', 'v'}, '<leader>gc', ':GitlinkFileCopy<CR>')
vim.keymap.set({'n', 'v'}, '<leader>gb', ':GitlinkBlameOpen<CR>')
vim.keymap.set({'n', 'v'}, '<leader>gv', ':GitlinkBlameCopy<CR>')
