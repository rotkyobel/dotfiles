-- Debug helpers for poking at running Neovim state.
--
-- The dump / leak-finder approach is adapted from craftzdog's dotfiles
-- (github.com/craftzdog/dotfiles), with vim.loop replaced by vim.uv, several
-- nil-guards added, and the error paths made explicit.

local M = {}

--- Source location of the caller, skipping this module and init.lua so the
--- reported location is the interesting one.
---@return string
function M.get_loc()
  local me = debug.getinfo(1, "S")
  local init = "@" .. (vim.env.MYVIMRC or "")
  local level = 2
  local info = debug.getinfo(level, "S")
  while info and (info.source == me.source or info.source == init or info.what ~= "Lua") do
    level = level + 1
    info = debug.getinfo(level, "S")
  end
  info = info or me
  local source = (info.source or ""):gsub("^@", "")
  source = (vim.uv or vim.loop).fs_realpath(source) or source
  return source .. ":" .. info.linedefined
end

--- Render a value in a floating notification, syntax highlighted as lua.
---@param value any
---@param opts? { loc: string }
function M._dump(value, opts)
  opts = opts or {}
  opts.loc = opts.loc or M.get_loc()

  -- Called from a fast event context (autocmd, callback): defer to the main loop.
  if vim.in_fast_event() then
    return vim.schedule(function()
      M._dump(value, opts)
    end)
  end

  opts.loc = vim.fn.fnamemodify(opts.loc, ":~:.")
  vim.notify(vim.inspect(value), vim.log.levels.INFO, {
    title = "Debug: " .. opts.loc,
    on_open = function(win)
      vim.wo[win].conceallevel = 3
      vim.wo[win].concealcursor = ""
      vim.wo[win].spell = false
      local buf = vim.api.nvim_win_get_buf(win)
      if not pcall(vim.treesitter.start, buf, "lua") then
        vim.bo[buf].filetype = "lua"
      end
    end,
  })
end

--- Dump one or more values. A single value is unwrapped so that
--- `dd(some_table)` shows the table itself rather than a one-element list.
function M.dump(...)
  local count = select("#", ...)
  if count == 0 then
    return M._dump(nil)
  elseif count == 1 then
    -- Explicit branch rather than an `and/or` chain so falsy values survive.
    return M._dump((...))
  end
  return M._dump({ ... })
end

--- Namespaces that are holding extmarks in live buffers, largest first.
--- A namespace that keeps growing here is leaking.
function M.extmark_leaks()
  local counts = {}
  for name, ns in pairs(vim.api.nvim_get_namespaces()) do
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      local count = #vim.api.nvim_buf_get_extmarks(buf, ns, 0, -1, {})
      if count > 0 then
        counts[#counts + 1] = { name = name, buf = buf, count = count, ft = vim.bo[buf].ft }
      end
    end
  end
  table.sort(counts, function(a, b)
    return a.count > b.count
  end)
  M.dump(counts)
end

--- Rough in-memory size of a value, following functions' upvalues.
---@param value any
---@param visited? table<any, true>
---@return number bytes
local function estimate_size(value, visited)
  if value == nil then
    return 0
  end

  visited = visited or {}
  if visited[value] then
    return 0
  end
  visited[value] = true

  local bytes = 0
  local kind = type(value)
  if kind == "boolean" then
    bytes = 4
  elseif kind == "number" then
    bytes = 8
  elseif kind == "string" then
    bytes = #value + 24
  elseif kind == "function" then
    bytes = 32
    local i = 1
    while true do
      local name, val = debug.getupvalue(value, i)
      if not name then
        break
      end
      bytes = bytes + estimate_size(val, visited)
      i = i + 1
    end
  elseif kind == "table" then
    bytes = 40
    for k, v in pairs(value) do
      bytes = bytes + estimate_size(k, visited) + estimate_size(v, visited)
    end
    local mt = debug.getmetatable(value)
    if mt then
      bytes = bytes + estimate_size(mt, visited)
    end
  end
  return bytes
end

--- Approximate memory held by each loaded lua module, biggest first.
--- Useful for finding startup bloat.
---@param filter? string only include modules matching this lua pattern
function M.module_leaks(filter)
  local sizes = {}
  for modname, mod in pairs(package.loaded) do
    if not filter or modname:match(filter) then
      local root = modname:match("^([^%.]+)%..*$") or modname
      sizes[root] = sizes[root] or { mod = root, size = 0 }
      sizes[root].size = sizes[root].size + estimate_size(mod) / 1024 / 1024
    end
  end

  local list = vim.tbl_values(sizes)
  table.sort(list, function(a, b)
    return a.size > b.size
  end)
  for _, entry in ipairs(list) do
    entry.size = ("%.2f MB"):format(entry.size)
  end
  M.dump(list)
end

return M
