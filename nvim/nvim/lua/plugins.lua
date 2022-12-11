-- install packer automatically
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  use 'nvim-lua/plenary.nvim'
  use 'lewis6991/impatient.nvim'
  -- use 'dstein64/vim-startuptime'

  use 'ggandor/leap.nvim'
  use 'romainl/vim-cool'
  use 'elzr/vim-json'
  use 'APZelos/blamer.nvim'
  use 'airblade/vim-gitgutter'
  use 'tpope/vim-commentary'

  use { 'nvim-telescope/telescope.nvim', requires = { 'nvim-lua/plenary.nvim' } }
  use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }

  use { 'nvim-tree/nvim-tree.lua', requires = { 'kyazdani42/nvim-web-devicons' } }
  use { 'goolord/alpha-nvim', requires = { 'kyazdani42/nvim-web-devicons' } }
  use { 'romgrk/barbar.nvim', requires = { 'kyazdani42/nvim-web-devicons' } }
  use { 'nvim-lualine/lualine.nvim', requires = { 'kyazdani42/nvim-web-devicons', opt = true } }

  -- automatically set up configuration after cloning packer.nvim
  -- keep after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end)
