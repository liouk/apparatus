local layouts = {
  small = {
    prompt_position = "bottom",
    width = function(_, max_columns, _)
      return math.min(max_columns-10, 80)
    end,
    height = function(_, _, max_lines)
      return math.min(max_lines, 15)
    end,
  },

  standard = {
    prompt_position = "bottom",
    width = function(_, max_columns, _)
      return math.min(max_columns-10, 90)
    end,
    height = function(_, _, max_lines)
      return math.min(max_lines, 20)
    end,
  },

  wide = {
    prompt_position = "bottom",
    width = function(_, max_columns, _)
      return math.min(max_columns-10, 110)
    end,
    height = function(_, _, max_lines)
      return math.min(max_lines, 20)
    end,
  },
}

require("telescope").setup({
  defaults = {
    vimgrep_arguments = {
      "rg",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
      "--trim",
    },
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
      theme = "dropdown",
      previewer = false,
      find_command = { "rg", "--files", "--iglob", "!.git", "--hidden" },
      sorting_strategy = "descending",
      layout_config = layouts.standard,
    },

    oldfiles = {
      previewer = false,
      theme = "dropdown",
      sorting_strategy = "descending",
      layout_config = layouts.standard,
    },

    buffers = {
      previewer = false,
      theme = "dropdown",
      sorting_strategy = "descending",
      layout_config = layouts.small,
    },

    live_grep = {
      only_sort_text = true,
      theme = "dropdown",
      sorting_strategy = "descending",
      layout_config = layouts.wide,
    },

    grep_string = {
      search = "",
      only_sort_text = true,
      theme = "dropdown",
      sorting_strategy = "descending",
      layout_config = layouts.wide,
    },
  },
})

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<C-p>", builtin.find_files)
vim.keymap.set("n", "<leader>r", builtin.oldfiles)
vim.keymap.set("n", "<leader>e", builtin.buffers)
vim.keymap.set("n", "<leader>f", builtin.grep_string)

-- use fzf native plugin
require("telescope").load_extension("fzf")
