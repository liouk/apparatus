local U = {}

local function notify(title, msg, level)
  local prefix = ''
  if title ~= '' and title ~= nil then
    prefix = title .. ': '
  end
  vim.notify(prefix..msg, level)
end

function U.startswith(str, prefix)
  return string.sub(str, 1, prefix:len()) == prefix
end

function U.endswith(str, suffix)
  local lstr = str:len()
  local lsuf = suffix:len()
  return str:sub(lstr-lsuf+1, lstr) == suffix
end

function U.wrn(msg, title) notify(title, msg, vim.log.levels.WARN) end
function U.err(msg, title) notify(title, msg, vim.log.levels.ERROR) end
function U.inf(msg, title) notify(title, msg, vim.log.levels.INFO) end

return U
