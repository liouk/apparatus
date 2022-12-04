require("telescope").setup({
  defaults = {
    mappings = {
      i = {
        ["<C-k>"] = "move_selection_previous",
        ["<C-j>"] = "move_selection_next",
        ["<Esc>"] = "close",
      },
      n = {
        ["<C-k>"] = "move_selection_previous",
        ["<C-j>"] = "move_selection_next",
      }
    },
  },
})

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<C-p>", builtin.find_files)
vim.keymap.set("n", "<leader>r", builtin.oldfiles)
vim.keymap.set("n", "<leader>e", builtin.buffers)
vim.keymap.set("n", "<leader>f", builtin.live_grep)
