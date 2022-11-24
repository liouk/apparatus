local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")

-- header
local function version()
  local version = vim.version()
  return "v" .. version.major .. '.' .. version.minor .. '.' .. version.patch
end

dashboard.section.header.val = '---=[ nvim ' .. version() .. ' ]=---'

-- menu
dashboard.section.buttons.val = {
    dashboard.button( "e", "  > new buffer" , ":enew <BAR> startinsert <CR>"),
    dashboard.button( "p", "  > find", ":FZF<CR>"),
    dashboard.button( "f", "  > grep", ":Rg<CR>"),
    dashboard.button( "r", "  > recent"   , ":History<CR>"),
    dashboard.button( "s", "  > vim config" , ":e $MYVIMRC<CR>"),
    dashboard.button( "q", "  > quit", ":qa<CR>"),
}

-- footer
dashboard.section.footer.val = vim.fn.getcwd()

-- send config to alpha
alpha.setup(dashboard.opts)

-- disable folding on alpha buffer
vim.cmd([[
    autocmd FileType alpha setlocal nofoldenable
]])
