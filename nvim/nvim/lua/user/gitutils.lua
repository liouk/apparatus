local G = {}
local Job = require('plenary.job')
local Path = require('plenary.path')
local Utils = require('user.utils')

function G.git(args, cwd)
  local output
  local exitcode
  Job:new({
    command = 'git',
    args = args,
    cwd = cwd or G.git_root(),
    on_exit = function(j, code)
      output = j:result()
      exitcode = code
    end,
  }):sync()
  return output, exitcode
end

function G.git_root(filepath)
  local fp = filepath or vim.api.nvim_buf_get_name(0)
  local res = G.git(
    {'rev-parse', '--show-toplevel'},
    tostring(Path:new(fp):parent())
  )[1]

  return res
end

function G.git_remote_url()
  local remote = G.git({'ls-remote', '--get-url'})[1]
  if remote then
  else
    return '', 'dir is not a git repo'
  end

  if Utils.startswith(remote, 'https://') then
    if Utils.endswith(remote, '.git') then
      remote = remote:sub(1, remote:len()-4)
    end
    return remote

  elseif Utils.startswith(remote, 'git@') then
    remote = remote:gsub(':', '/', 1)
    remote = remote:gsub('git@', 'https://', 1)
    if Utils.endswith(remote, '.git') then
      remote = remote:sub(1, remote:len()-4)
    end
    return remote
  end

  return '', 'could not determine git remote: ' .. remote
end

function G.git_repo_name()
  local remote_url = G.git_remote_url()
  local parts = vim.split(remote_url, '/', true)
  return parts[#parts]
end

return G
