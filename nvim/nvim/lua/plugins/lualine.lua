local function repo()
  local Job = require('plenary.job')
  local git_remote
  local exitcode
  Job:new({
    command = 'git',
    args = {'config', '--get', 'remote.origin.url'},
    on_exit = function(j, code)
      git_remote = j:result()[1]
      exitcode = code
    end,
  }):sync()

  if exitcode > 0 then
    return ""
  end

  local prefix = "git@github.com:"
  local suffix = ".git"
  local reponame
  if string.sub(git_remote, 1, prefix:len()) == prefix then
    reponame = string.sub(git_remote, prefix:len()+1, git_remote:len()-suffix:len())
  else
    return ""
  end

  return reponame
end

return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  event = 'VeryLazy',

  config = function()
    require('lualine').setup({
      options = {
        theme = 'auto',
        disabled_filetypes = { 'packer', 'NvimTree' },
        component_separators = { left = '', right = ''},
        section_separators = { left = '', right = ''},
      },
      sections = {
        lualine_a = {'mode'},
        lualine_b = {{repo, icon = '󰊢'}, {'branch', icon = ''} , 'diff', 'diagnostics'},
        lualine_c = {{'filename', path = 1}},
        lualine_x = {},
        lualine_y = {'filetype'},
        lualine_z = {'location'}
      },
    })
  end,
}
