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
  use "nvim-lua/plenary.nvim"

  use { 'ggandor/leap.nvim', config = function () require('leap').add_default_mappings() end }
  -- use my own fork until https://github.com/goolord/alpha-nvim/pull/160 gets merged
  use { 'liouk/alpha-nvim', branch = 'theta-mru', requires = { 'kyazdani42/nvim-web-devicons' } }

  -- automatically set up configuration after cloning packer.nvim
  -- keep after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end)