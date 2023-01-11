return {
  'neovim/nvim-lspconfig',
  lazy = false,
  dependencies = {
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'hrsh7th/nvim-cmp',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
  },

  config = function()
    local cmp = require('cmp')
    cmp.setup({
      completion = {
        autocomplete = false,
      },
      mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping(cmp.mapping.complete({
          reason = cmp.ContextReason.Auto,
        }), {'i', 'c'}),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<C-y>'] = cmp.mapping.confirm({ select = false }),
      }),
      sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'buffer' },
      }),
    })

    require('mason').setup()
    require('mason-lspconfig').setup({
      ensure_installed = {
        'bashls',
        'dockerls',
        'golangci_lint_ls',
        'gopls',
        'sumneko_lua',
        'yamlls',
      }
    })

    local lspconfig = require('lspconfig')
    local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()
    local lsp_attach = function(_, bufnr)
      local opts = { buffer = bufnr, remap = false }
      vim.keymap.set('n', 'gd', function() vim.lsp.buf.definition() end, opts)
      vim.keymap.set('n', 'K', function() vim.lsp.buf.hover() end, opts)
      vim.keymap.set('n', '[d', function() vim.diagnostic.goto_next() end, opts)
      vim.keymap.set('n', ']d', function() vim.diagnostic.goto_prev() end, opts)
    end

    require('mason-lspconfig').setup_handlers({
      function(server_name)
        lspconfig[server_name].setup({
          on_attach = lsp_attach,
          capabilities = lsp_capabilities,
        })
      end
    })

    lspconfig.sumneko_lua.setup({
      settings = {
        Lua = {
          diagnostics = { globals = { 'vim' } },
          telemetry = { enable = false },
        },
      },
    })

  end,
}
