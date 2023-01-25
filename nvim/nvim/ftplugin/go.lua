-- go uses tabs, so don't expand them to spaces
vim.opt.expandtab = false

-- invoke gofmt+goimport from go.nvim instead of simply retabbing
vim.keymap.set('n', '<leader>t', ':GoImport<CR>', { desc = 'Invoke gofmt+goimport [go.nvim]', buffer = true })
vim.keymap.set('n', '<leader>b', ':GoBuild<CR>', { desc = 'Invoke go build [go.nvim]', buffer = true })
