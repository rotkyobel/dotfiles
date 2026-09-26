-- Report which LSP servers this config enables and whether their Mason
-- packages are actually present.
--
--   nvim -i NONE --headless -c "luafile scripts/lsp-status.lua" -c "qa!"
--
-- Useful because a server whose Mason package is missing is silently not
-- enabled: no error, just no client.
require("lazy").load({ plugins = { "nvim-lspconfig", "mason.nvim", "mason-lspconfig.nvim" } })

local Config = require("lazy.core.config")
local Plugin = require("lazy.core.plugin")
local registry = require("mason-registry")
local mapping = require("mason-lspconfig.mappings").get_mason_map().lspconfig_to_package

---@type table<string, { enabled: boolean, mason: any }>
local servers = {}
for _, plugin in pairs(Config.plugins) do
  local ok, opts = pcall(Plugin.values, plugin, "opts")
  if ok and type(opts) == "table" and type(opts.servers) == "table" then
    for name, sopts in pairs(opts.servers) do
      if name ~= "*" then
        if sopts == true then
          sopts = {}
        elseif not sopts then
          sopts = { enabled = false }
        end
        servers[name] = servers[name] or {}
        if sopts.enabled == false then
          servers[name].enabled = false
        elseif servers[name].enabled == nil then
          servers[name].enabled = true
        end
      end
    end
  end
end

local names = vim.tbl_keys(servers)
table.sort(names)

print("[lsp] server                     enabled  mason-package                 present")
for _, name in ipairs(names) do
  local pkg = mapping[name] or "-"
  local present = "n/a"
  if pkg ~= "-" then
    local ok, p = pcall(registry.get_package, pkg)
    if ok then
      -- fs_stat follows symlinks, unlike vim.fn.executable().
      present = tostring(p:is_installed() and vim.uv.fs_stat(vim.fn.stdpath("data") .. "/mason/packages/" .. pkg) ~= nil)
    else
      present = "no-pkg"
    end
  end
  print(("[lsp] %-26s %-8s %-29s %s"):format(name, tostring(servers[name].enabled), pkg, present))
end

local enabled = {}
if vim.lsp._enabled_configs then
  for name in pairs(vim.lsp._enabled_configs) do
    enabled[#enabled + 1] = name
  end
  table.sort(enabled)
end
print("[lsp] runtime enabled configs: " .. table.concat(enabled, ", "))
print("[lsp] mason/bin on PATH: " .. tostring(vim.env.PATH:find("mason/bin") ~= nil))
