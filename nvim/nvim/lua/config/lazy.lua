-- install lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  spec = {
    -- 'plugins' module contains all plugin definitions and configs
    -- lua/plugins/init.lua defines all plugins that don't require a config
    -- lua/plugins/<plugin>.lua contains the definition and config for every plugin that requires one
    import = "plugins",
  },
  defaults = { lazy = false },
  install = { colorscheme = { "catppuccin" } },
})
