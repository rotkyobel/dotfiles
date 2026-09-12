-- Install every Mason package this config declares, in a way that survives
-- headless Neovim exiting.
--
-- Run after any `Lazy! sync`:
--   nvim -i NONE --headless -c "luafile scripts/mason-sync.lua" -c "qa!"
--
-- Two traps this works around:
--   * Headless `Lazy! sync` exits while Mason is still installing, aborting it.
--   * `vim.fn.executable()` returns 1 for a dangling symlink, and Mason creates
--     the bin symlink early, so only `vim.uv.fs_stat()` is trustworthy here.
require("lazy").load({ plugins = { "nvim-lspconfig", "mason.nvim", "mason-lspconfig.nvim" } })

local Config = require("lazy.core.config")
local Plugin = require("lazy.core.plugin")
local registry = require("mason-registry")
local mapping = require("mason-lspconfig.mappings").get_mason_map().lspconfig_to_package
local roots = vim.fn.stdpath("data") .. "/mason"

---@type table<string, string> package name -> why it is wanted
local wanted = {}

-- 1. Mason's own ensure_installed lists. Only mason's specs are read here:
--    nvim-treesitter reuses the same opts key for parser names.
for _, name in ipairs({ "mason.nvim", "mason-lspconfig.nvim", "mason-tool-installer.nvim" }) do
  local plugin = Config.plugins[name]
  if plugin then
    local ok, opts = pcall(Plugin.values, plugin, "opts")
    if ok and type(opts) == "table" and type(opts.ensure_installed) == "table" then
      for _, pkg in ipairs(opts.ensure_installed) do
        wanted[pkg] = "ensure_installed"
      end
    end
  end
end

-- 2. The LSP servers LazyVim enables, using LazyVim's own filter rules.
for _, plugin in pairs(Config.plugins) do
  local ok, opts = pcall(Plugin.values, plugin, "opts")
  if ok and type(opts) == "table" and type(opts.servers) == "table" then
    for server, sopts in pairs(opts.servers) do
      if server ~= "*" then
        if sopts == true then
          sopts = {}
        elseif not sopts then
          sopts = { enabled = false }
        end
        local pkg = mapping[server]
        if sopts.enabled ~= false and sopts.mason ~= false and pkg then
          wanted[pkg] = wanted[pkg] or ("lsp:" .. server)
        end
      end
    end
  end
end

local function landed(name)
  return vim.uv.fs_stat(roots .. "/packages/" .. name) ~= nil
end

local pending = {}
for name, why in pairs(wanted) do
  local ok, pkg = pcall(registry.get_package, name)
  if not ok then
    print(("[skip]   %-32s not in registry (%s)"):format(name, why))
  elseif not (pkg:is_installed() and landed(name)) then
    pending[#pending + 1] = { pkg = pkg, why = why, state = "pending" }
  end
end

table.sort(pending, function(a, b)
  return a.pkg.name < b.pkg.name
end)

print(("[mason] %d wanted, %d to install"):format(vim.tbl_count(wanted), #pending))

for _, item in ipairs(pending) do
  print(("[mason] installing %-32s (%s)"):format(item.pkg.name, item.why))
  -- Wait for Mason's own completion event, never for a filesystem side effect.
  pcall(function()
    item.pkg:on("install:success", function()
      item.state = "success"
    end)
    item.pkg:on("install:failed", function()
      item.state = "failed"
    end)
  end)
  pcall(item.pkg.install, item.pkg)
end

local finished = vim.wait(1800000, function()
  for _, item in ipairs(pending) do
    if item.state == "pending" then
      return false
    end
  end
  return true
end, 1000)

local failed = 0
for _, item in ipairs(pending) do
  local ok = item.pkg:is_installed() and landed(item.pkg.name)
  if not ok then
    failed = failed + 1
  end
  print(("[mason]   %-32s state=%-8s installed=%s"):format(item.pkg.name, item.state, tostring(ok)))
end
print(("[mason] finished=%s failures=%d"):format(tostring(finished), failed))
