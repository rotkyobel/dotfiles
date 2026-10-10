-- Keeps Neovim's colorscheme in sync with the active Ghostty theme.
--
-- Ghostty selects a theme with `theme = <name>` in ~/.config/ghostty/config
-- and rewrites that file in place when toggled (ctrl+shift+y), signalling its
-- own reload. Neovim cannot observe that, so the theme is applied at startup
-- and re-applied on demand with <leader>ct, :ThemeSync, or by saving the
-- Ghostty config from inside Neovim (see lua/config/autocmds.lua).

local M = {}

M.config = vim.fn.expand("~/.config/ghostty/config")

--- Ghostty theme name -> how Neovim should render it.
--- The catppuccin palette overrides for "Catppuccin Espresso" live in
--- lua/plugins/theme.lua; "Deep Tide" is a standalone colorscheme in colors/.
M.themes = {
  ["Catppuccin Espresso"] = { colorscheme = "catppuccin-macchiato", plugin = "catppuccin" },
  ["Deep Tide"] = { colorscheme = "deep_tide" },
}

--- Used when the Ghostty config is missing or names a theme we do not know.
M.fallback = "Catppuccin Espresso"

--- Accent colors for UI plugins that need concrete values rather than
--- highlight links (incline, statusline chunks, ...).
M.ui = {
  ["Catppuccin Espresso"] = { accent = "#c6a0f6", accent_fg = "#0a0a0a", surface = "#363a4f" },
  ["Deep Tide"] = { accent = "#c084fc", accent_fg = "#010608", surface = "#13333c" },
}

--- Highlight groups that should have no background so Ghostty's window
--- opacity and blur show through.
M.transparent = {
  "Normal",
  "NormalNC",
  "NormalFloat",
  "FloatBorder",
  "FloatTitle",
  "SignColumn",
  "EndOfBuffer",
}

--- Currently applied Ghostty theme name, if any.
M.active = nil

--- Read the `theme = ...` line from the Ghostty config.
---@return string? name
function M.current()
  if vim.fn.filereadable(M.config) == 0 then
    return nil
  end
  local ok, lines = pcall(vim.fn.readfile, M.config)
  if not ok or type(lines) ~= "table" then
    return nil
  end
  for _, line in ipairs(lines) do
    local name = line:match("^%s*theme%s*=%s*(.-)%s*$")
    if name and name ~= "" then
      return name
    end
  end
  return nil
end

--- Strip backgrounds from the transparent groups.
function M.clear_backgrounds()
  for _, group in ipairs(M.transparent) do
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
    if ok and hl then
      hl.bg = nil
      vim.api.nvim_set_hl(0, group, hl)
    end
  end
end

---@return { accent: string, accent_fg: string, surface: string }
function M.ui_colors()
  return M.ui[M.active or ""] or M.ui[M.fallback]
end

--- Apply the colorscheme matching the active Ghostty theme.
function M.apply()
  local name = M.current()
  local theme = name and M.themes[name] or nil

  if name and not theme then
    vim.notify(
      ("Unknown Ghostty theme %q, falling back to %q"):format(name, M.fallback),
      vim.log.levels.WARN,
      { title = "Theme" }
    )
  end

  -- M.active records what was actually applied, so an unknown or missing
  -- Ghostty theme has to resolve to the fallback here too.
  if theme then
    M.active = name
  else
    theme = M.themes[M.fallback]
    M.active = M.fallback
  end

  -- Ensure the plugin providing the colorscheme is on the runtimepath before
  -- `:colorscheme` looks it up.
  if theme.plugin then
    pcall(require, theme.plugin)
  end

  local ok = pcall(vim.cmd.colorscheme, theme.colorscheme)
  if not ok then
    vim.cmd.colorscheme("habamax")
  end

  M.clear_backgrounds()
end

--- Re-apply after the Ghostty theme changed.
function M.sync()
  M.apply()
  vim.notify(("Theme: %s"):format(M.active or "unknown"), vim.log.levels.INFO, { title = "Theme" })
end

vim.api.nvim_create_user_command("ThemeSync", function()
  M.sync()
end, { desc = "Re-apply the Ghostty theme" })

return M
