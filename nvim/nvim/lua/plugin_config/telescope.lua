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
      previewer = false,
      theme = "dropdown",
      sorting_strategy = "descending",
      layout_config = layouts.standard,
      find_command = { "rg", "--files", "--iglob", "!.git", "--hidden" },
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
      theme = "dropdown",
      sorting_strategy = "descending",
      layout_config = layouts.wide,
      only_sort_text = true,
    },

    grep_string = {
      theme = "dropdown",
      sorting_strategy = "descending",
      layout_config = layouts.wide,
      only_sort_text = true,
      search = "",
    },

    current_buffer_fuzzy_find = {
      theme = "dropdown",
      sorting_strategy = "descending",
      layout_config = layouts.small,
    }
  },
})

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<C-p>", builtin.find_files)
vim.keymap.set("n", "<leader>r", builtin.oldfiles)
vim.keymap.set("n", "<leader>e", builtin.buffers)
vim.keymap.set("n", "<leader>f", builtin.grep_string)
vim.keymap.set("n", "<C-f>", builtin.current_buffer_fuzzy_find)

-- use fzf native plugin
require("telescope").load_extension("fzf")
