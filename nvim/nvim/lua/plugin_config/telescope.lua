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

local function find_files_with_hidden()
  builtin.find_files {
    find_command = { 'rg', '--files', '--iglob', '!.git', '--hidden' },
  }
end

vim.keymap.set("n", "<C-p>", find_files_with_hidden)
vim.keymap.set("n", "<leader>r", builtin.oldfiles)
vim.keymap.set("n", "<leader>e", builtin.buffers)
vim.keymap.set("n", "<leader>f", builtin.live_grep)

-- use fzf native plugin
require("telescope").load_extension("fzf")
