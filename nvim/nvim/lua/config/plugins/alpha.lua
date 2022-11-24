local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")

-- Set header
dashboard.section.header.val = {
    "███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
    "████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
    "██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
    "██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
    "██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
    "╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
}

-- Set menu
dashboard.section.buttons.val = {
    dashboard.button( "e", "  > New buffer" , ":enew <BAR> startinsert <CR>"),
    dashboard.button( "f", "  > Find file", ":FZF<CR>"),
    dashboard.button( "r", "  > Recent"   , ":History<CR>"),
    dashboard.button( "s", "  > Settings" , ":e $MYVIMRC<CR>"),
    dashboard.button( "q", "  > Quit NVIM", ":qa<CR>"),
}

-- Set footer
dashboard.section.footer.val = vim.fn.getcwd()

-- Send config to alpha
alpha.setup(dashboard.opts)

-- Disable folding on alpha buffer
vim.cmd([[
    autocmd FileType alpha setlocal nofoldenable
]])
