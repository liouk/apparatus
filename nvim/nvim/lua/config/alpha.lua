local dashboard = require("alpha.themes.dashboard")
local theta = require("alpha.themes.theta")
local config = theta.config
local cwd = vim.fn.getcwd()

-- header
local header = {
  "           9   /   F       J",
  "    l  μ   r   t   =       λ  i  |",
  " A  4  V   Y   3   T   @   ?  .  _",
  " y  *  -   $   r   <   ω   8  ?  Q",
  " .  :  n   e   o   v   i   m  :  .",
  " b  ;  {   f   ]   h   X   <  v  k",
  "    o  &   f   d   H       0  θ  E",
  "           D       %          ¢  0",
}

local function matrix_random()
  local charset = "1234567890" ..
    "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM" ..
    -- following charsets not rendered correctly
    -- "αβγδεζηθικλμνξοπρσςτυφχψωΓΔΘΛΞΠΣΦΨΩ" ..
    -- "£¢≠¥øƒ∫√" ..
    "~!@#$%^&*()-=_+[]{};':\",./<>?"
  math.randomseed(os.clock())

  local ret = {}
  local r
  local length = 51
  for i = 1, length do
    r = math.random(1, #charset)
    table.insert(ret, charset:sub(r, r))
  end
  local matrix_chars = table.concat(ret)

  local i = 0
  local function c()
    i = i + 1
    return matrix_chars:sub(i, i)
  end
  local spc = " "

 return {
    string.format("%4s%4s%4s%4s%4s%4s%4s%4s%4s%4s", spc, c(), spc, spc, c(), c(), spc, spc, spc, c()),
    string.format("%4s%4s%4s%4s%4s%4s%4s%4s%4s%4s", spc, c(), c(), spc, c(), c(), spc, c(), spc, c()),
    string.format("%4s%4s%4s%4s%4s%4s%4s%4s%4s%4s", c(), c(), c(), spc, c(), c(), c(), c(), c(), c()),
    string.format("%4s%4s%4s%4s%4s%4s%4s%4s%4s%4s", c(), c(), c(), c(), c(), c(), c(), c(), c(), c()),
    "  .   :   n   e   o   v   i   m   :   .",
    string.format("%4s%4s%4s%4s%4s%4s%4s%4s%4s%4s", c(), c(), c(), c(), c(), c(), c(), c(), c(), c()),
    string.format("%4s%4s%4s%4s%4s%4s%4s%4s%4s%4s", spc, c(), c(), c(), c(), c(), spc, c(), c(), c()),
    string.format("%4s%4s%4s%4s%4s%4s%4s%4s%4s%4s", spc, spc, spc, c(), spc, c(), spc, spc, c(), c()),
  }
end

-- uncomment to get random matrix chars every time
-- header = matrix_random()

-- mru_files
local mru_files = config.layout[4]
mru_files.val[3] = {
  type = "group",
  val = function()
    return { theta.mru(0, cwd, 5) }
  end,
  opts = { shrink_margin = false },
}

-- buttons
local buttons = config.layout[6]
buttons.val = {
  dashboard.button("e", "  new buffer",     "<cmd>enew <BAR> startinsert <CR>"),
  dashboard.button("d", "  explore dir",    "<cmd>BW<CR><cmd>NERDTreeToggle<CR>"),
  dashboard.button("p", "  find here",      "<cmd>FZF<CR>"),
  dashboard.button("f", "  grep here",      "<cmd>Rg<CR>"),
  dashboard.button("r", "  search recent",  "<cmd>History<CR>"),
  dashboard.button("s", "  vim config" ,    "<cmd>e $MYVIMRC<CR>"),
  dashboard.button("u", "  update plugins", "<cmd>PackerSync<CR>"),
  dashboard.button("q", "  quit",           "<cmd>qa<CR>"),
}

-- footer
local function fn_short(fn)
  local plenary_path = require("plenary.path")
  local target_width = 70
  local short_fn = vim.fn.fnamemodify(fn, ":~")
  short_fn = vim.fn.fnamemodify(short_fn, ":s?\\~/Workspace/personal/github.com/?<github>/?")

  return short_fn
end

local v = vim.version()
local plugins_count = vim.fn.len(vim.fn.globpath("~/.local/share/nvim/site/pack/packer/start", "*", 0, 1))

-- set current config
config.layout = {
  -- header
  { type = "padding", val = 2 },
  { type = "text", val = header[1], opts = { hl = "GruvboxGreen", shrink_margin = false, position = "center" } },
  { type = "text", val = header[2], opts = { hl = "GruvboxGreen", shrink_margin = false, position = "center" } },
  { type = "text", val = header[3], opts = { hl = "GruvboxGreen", shrink_margin = false, position = "center" } },
  { type = "text", val = header[4], opts = { hl = "GruvboxGreen", shrink_margin = false, position = "center" } },
  { type = "text", val = header[5], opts = { hl = "htmlBold", shrink_margin = false, position = "center" } },
  { type = "text", val = header[6], opts = { hl = "GruvboxGreen", shrink_margin = false, position = "center" } },
  { type = "text", val = header[7], opts = { hl = "GruvboxGreen", shrink_margin = false, position = "center" } },
  { type = "text", val = header[8], opts = { hl = "GruvboxGreen", shrink_margin = false, position = "center" } },

  -- recent files
  { type = "padding", val = 2 },
  mru_files,

  -- quick links
  { type = "padding", val = 1 },
  { type = "text", val = "Quick links", opts = { hl = "SpecialComment", position = "center" } },
  { type = "padding", val = 1 },
  buttons,

  -- footer
  { type = "padding", val = 2 },
  { type = "text", val = " nvim v"..v.major.."."..v.minor.."."..v.patch, opts = { hl = "GruvboxBg4", shrink_margin = false, position = "center", } },
  { type = "text", val = " "..plugins_count.." plugins", opts = { hl = "GruvboxBg4", shrink_margin = false, position = "center", } },
  { type = "text", val = " "..fn_short(cwd), opts = { position = "center", hl = "GruvboxBg4", } },
}

require("alpha").setup(config)

-- disable folding on alpha buffer
vim.cmd([[
    autocmd FileType alpha setlocal nofoldenable
]])
