return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  event = 'VeryLazy',

  config = function()
    require('nvim-treesitter.configs').setup({
      ensure_installed = {
        'bash',
        'dockerfile',
        'go',
        'help',
        'jq',
        'json',
        'lua',
        'make',
        'markdown',
        'python',
        'vim',
        'yaml',
      },

      sync_install = false,
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
    })
  end,
}
