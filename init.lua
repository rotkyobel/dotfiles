-- Byte-compile lua modules on load. Cheap startup win, no side effects.
if vim.loader then
  vim.loader.enable()
end

-- Dump any value in a floating notification, highlighted as lua.
-- Usage: dd(some_table)  or  :lua dd(vim.lsp.get_clients())
_G.dd = function(...)
  require("bscenez.debug").dump(...)
end

-- Route vim.print through dd() so ad-hoc debugging looks the same everywhere.
-- Values are still returned, so `local x = vim.print(v)` keeps working.
vim.print = function(...)
  require("bscenez.debug").dump(...)
  return ...
end

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
