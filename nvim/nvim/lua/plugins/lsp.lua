return {
  'neovim/nvim-lspconfig',
  event = 'BufReadPre',
  dependencies = {
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'hrsh7th/nvim-cmp',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/vim-vsnip',
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
        ['<CR>'] = cmp.mapping.confirm({
          behavior = cmp.ConfirmBehavior.Insert,
          select = true,
        }),
        ['<Tab>'] = cmp.mapping.confirm({
          behavior = cmp.ConfirmBehavior.Insert,
          select = true,
        }),
      }),
      snippet = {
        expand = function(args)
          vim.fn['vsnip#anonymous'](args.body)
        end,
      },
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
        'lua_ls',
        'yamlls',
      }
    })

    local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()
    local opts = function(bufnr, desc) return { buffer = bufnr, noremap = true, silent = true, desc = desc } end
    local lsp_attach = function(_, bufnr)
      vim.keymap.set('n', 'K',  function() vim.lsp.buf.hover() end,             opts(bufnr, 'lsp.buf.hover'))
      vim.keymap.set('n', 'gd', function() vim.lsp.buf.definition() end,        opts(bufnr, 'lsp.buf.definition'))
      vim.keymap.set('n', 'gD', function() vim.lsp.buf.declaration() end,       opts(bufnr, 'lsp.buf.declaration'))
      vim.keymap.set('n', 'gi', function() vim.lsp.buf.implementation() end,    opts(bufnr, 'lsp.buf.implementation'))
      vim.keymap.set('n', 'go', function() vim.lsp.buf.type_definition() end,   opts(bufnr, 'lsp.buf.type_definition'))
      vim.keymap.set('n', 'gn', function() vim.lsp.buf.rename() end,            opts(bufnr, 'lsp.buf.rename'))
      vim.keymap.set('n', 'ga', function() vim.lsp.buf.code_action() end,       opts(bufnr, 'lsp.buf.code_action'))
      vim.keymap.set('x', 'ga', function() vim.lsp.buf.range_code_action() end, opts(bufnr, 'lsp.buf.range_code_action'))
      vim.keymap.set('n', 'gs', function() vim.lsp.buf.signature_help() end,    opts(bufnr, 'lsp.buf.signature_help'))
      vim.keymap.set('n', 'gl', function() vim.diagnostic.open_float() end,     opts(bufnr, 'diagnostic.open_float'))
      vim.keymap.set('n', '[d', function() vim.diagnostic.goto_next() end,      opts(bufnr, 'diagnostic.goto_next'))
      vim.keymap.set('n', ']d', function() vim.diagnostic.goto_prev() end,      opts(bufnr, 'diagnostic.goto_prev'))
      vim.keymap.set('n', '<leader>t', function() vim.lsp.buf.format() end,     opts(bufnr, 'lsp.buf.format'))
    end

    local lspconfig = require('lspconfig')
    require('mason-lspconfig').setup_handlers({
      function(server_name)

        -- settings for all servers
        local server_setup = {
          on_attach = lsp_attach,
          capabilities = lsp_capabilities,
        }

        -- server-specific setup
        if server_name == 'lua_ls' then
          server_setup.settings = {
            Lua = {
              diagnostics = { globals = { 'vim' } },
              telemetry = { enable = false },
            },
          }
        end

        lspconfig[server_name].setup(server_setup)
      end
    })

  end,
}
