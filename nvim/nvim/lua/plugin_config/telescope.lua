require("telescope").setup({
  defaults = {
    mappings = {
      i = {
        ["<C-k>"] = "move_selection_previous",
        ["<C-j>"] = "move_selection_next",
        ["<Esc>"] = "close",
        ["<C-u>"] = false
      },
      n = {
        ["<C-k>"] = "move_selection_previous",
        ["<C-j>"] = "move_selection_next",
      }
    },
  },
  pickers = {
    find_files = {
      previewer = false,
      find_command = { 'rg', '--files', '--iglob', '!.git', '--hidden' },
    },
    oldfiles = { previewer = false },
    buffers = { previewer = false },
    live_grep = { only_sort_text = true },
  },
})

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<C-p>", builtin.find_files)
vim.keymap.set("n", "<leader>r", builtin.oldfiles)
vim.keymap.set("n", "<leader>e", builtin.buffers)
vim.keymap.set("n", "<leader>f", builtin.live_grep)

-- use fzf native plugin
require("telescope").load_extension("fzf")
