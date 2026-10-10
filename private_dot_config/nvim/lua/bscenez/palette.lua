-- Regenerates the palette block of a colorscheme generated from a Ghostty
-- theme. Used by scripts/deep-tide.lua, and asserted against the committed
-- colorscheme by scripts/verify.lua.
--
-- Most of the palette is a straight copy of the Ghostty theme, with no
-- interpretation:
--
--   background            ->  bg
--   foreground            ->  fg
--   cursor-color          ->  cursor
--   selection-background  ->  selection
--   palette 0..15         ->  black, red, ... bright_white
--
-- The remaining tokens are surfaces that Ghostty has no equivalent for. They
-- are kept as explicit constants per theme rather than derived, because they do
-- not reproduce from any blend of the palette: for every pair of palette
-- colours, no single alpha reproduces them within rounding. M.derived records
-- the background and selection each set was tuned against, and M.render warns
-- when the Ghostty theme has since moved off them — hand-tuned values quietly
-- inherited across a theme change are worse than a warning.

local M = {}

--- Where Ghostty keeps its named themes.
M.themes_dir = vim.fn.expand("~/.config/ghostty/themes")

--- Ghostty palette index -> field name in the generated table.
M.palette_fields = {
  [0] = "black",
  [1] = "red",
  [2] = "green",
  [3] = "yellow",
  [4] = "blue",
  [5] = "magenta",
  [6] = "cyan",
  [7] = "white",
  [8] = "bright_black",
  [9] = "bright_red",
  [10] = "bright_green",
  [11] = "bright_yellow",
  [12] = "bright_blue",
  [13] = "bright_magenta",
  [14] = "bright_cyan",
  [15] = "bright_white",
}

--- Ghostty theme name -> the surfaces only Neovim needs.
--- `tuned_bg` / `tuned_selection` are the Ghostty values these were picked
--- against; they are the guard described at the top of this file.
M.derived = {
  ["Deep Tide"] = {
    tuned_bg = "#010608",
    tuned_selection = "#13333c",
    surface = "#0a1519",
    surface_alt = "#0d1f25",
    diff_add = "#0d2a1f",
    diff_change = "#0d2430",
    diff_delete = "#2a1220",
  },
}

--- Fields read from the theme file, in the order they are emitted.
local SCALAR_KEYS = {
  { key = "background", field = "bg" },
  { key = "foreground", field = "fg" },
  { key = "cursor-color", field = "cursor" },
  { key = "selection-background", field = "selection" },
}

--- Parse a Ghostty theme file.
---@param theme string theme name, exactly as it appears after `theme =`
---@return table? values { bg, fg, cursor, selection, palette = { [0..15] } }
---@return string? err
function M.parse(theme)
  local path = ("%s/%s"):format(M.themes_dir, theme)
  if vim.fn.filereadable(path) == 0 then
    return nil, ("theme file not readable: %s"):format(path)
  end

  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok or type(lines) ~= "table" then
    return nil, ("could not read %s"):format(path)
  end

  local values = { palette = {} }
  for _, line in ipairs(lines) do
    local key, value = line:match("^%s*([%w_%-]+)%s*=%s*(.-)%s*$")
    if key and value ~= "" then
      if key == "palette" then
        -- Repeatable: `palette = 0=#061215`. The leading # is optional in
        -- Ghostty, so accept both and normalise.
        local index, hex = value:match("^(%d+)%s*=%s*#?(%x%x%x%x%x%x)$")
        if index then
          values.palette[tonumber(index)] = "#" .. hex:lower()
        end
      else
        for _, entry in ipairs(SCALAR_KEYS) do
          if key == entry.key then
            values[entry.field] = "#" .. value:gsub("^#", ""):lower()
          end
        end
      end
    end
  end

  -- Refuse a partial palette: a missing entry would silently become nil in the
  -- generated table and drop a highlight instead of failing loudly.
  local missing = {}
  for _, entry in ipairs(SCALAR_KEYS) do
    if not values[entry.field] then
      missing[#missing + 1] = entry.key
    end
  end
  for index = 0, 15 do
    if not values.palette[index] then
      missing[#missing + 1] = ("palette %d"):format(index)
    end
  end
  if #missing > 0 then
    return nil, ("%s is missing: %s"):format(path, table.concat(missing, ", "))
  end

  return values
end

--- Render the `local c = { ... }` block for a theme.
---@param theme string
---@return string? block
---@return string[] warnings
---@return string? err
function M.render(theme)
  local values, err = M.parse(theme)
  if not values then
    return nil, {}, err
  end

  local derived = M.derived[theme]
  if not derived then
    return nil, {}, ("no hand-tuned surfaces for %q; add them to M.derived"):format(theme)
  end

  local warnings = {}
  if derived.tuned_bg ~= values.bg then
    warnings[#warnings + 1] = ("background moved %s -> %s; re-check the hand-tuned surfaces in M.derived"):format(
      derived.tuned_bg,
      values.bg
    )
  end
  if derived.tuned_selection ~= values.selection then
    warnings[#warnings + 1] = ("selection moved %s -> %s; re-check the hand-tuned surfaces in M.derived"):format(
      derived.tuned_selection,
      values.selection
    )
  end

  local lines = {
    "local c = {",
    '  none = "NONE",',
    ('  bg = "%s",'):format(values.bg),
    ('  fg = "%s",'):format(values.fg),
  }
  for index = 0, 15 do
    lines[#lines + 1] = ('  %s = "%s",'):format(M.palette_fields[index], values.palette[index])
  end
  lines[#lines + 1] = ('  cursor = "%s",'):format(values.cursor)
  lines[#lines + 1] = ('  selection = "%s",'):format(values.selection)
  lines[#lines + 1] = "  -- surfaces: no Ghostty equivalent, hand-tuned (see lua/bscenez/palette.lua)"
  lines[#lines + 1] = ('  surface = "%s",'):format(derived.surface)
  lines[#lines + 1] = ('  surface_alt = "%s",'):format(derived.surface_alt)
  lines[#lines + 1] = "  -- diff backgrounds, tinted from green / blue / red"
  lines[#lines + 1] = ('  diff_add = "%s",'):format(derived.diff_add)
  lines[#lines + 1] = ('  diff_change = "%s",'):format(derived.diff_change)
  lines[#lines + 1] = ('  diff_delete = "%s",'):format(derived.diff_delete)
  lines[#lines + 1] = "}"

  return table.concat(lines, "\n"), warnings
end

--- Locate the generated block in an existing colorscheme file.
---@param lines string[]
---@return number? first index of the `local c = {` line
---@return number? last index of its closing `}`
local function find_block(lines)
  for i, line in ipairs(lines) do
    if line:match("^local c = {%s*$") then
      for j = i + 1, #lines do
        if lines[j] == "}" then
          return i, j
        end
      end
      return i, nil
    end
  end
  return nil, nil
end

--- Regenerate the palette block inside an existing colorscheme file, leaving
--- the hand-written highlight groups below it untouched.
---@param theme string
---@param path string colorscheme file to read, and to rewrite when mode is "write"
---@param mode "check"|"write"
---@return boolean ok
---@return string message
---@return string[] warnings
function M.sync(theme, path, mode)
  local block, warnings, err = M.render(theme)
  warnings = warnings or {}
  if not block then
    return false, err or ("cannot render the %s theme"):format(theme), warnings
  end

  if vim.fn.filereadable(path) == 0 then
    return false, ("%s does not exist; cannot regenerate in place"):format(path), warnings
  end

  local ok_read, lines = pcall(vim.fn.readfile, path)
  if not ok_read then
    return false, ("could not read %s"):format(path), warnings
  end

  local first, last = find_block(lines)
  if not first then
    return false, ("no `local c = {` block found in %s"):format(path), warnings
  end
  if not last then
    return false, ("unterminated `local c = {` block in %s"):format(path), warnings
  end

  local new = {}
  for i = 1, first - 1 do
    new[#new + 1] = lines[i]
  end
  for _, line in ipairs(vim.split(block, "\n", { plain = true })) do
    new[#new + 1] = line
  end
  for i = last + 1, #lines do
    new[#new + 1] = lines[i]
  end

  if vim.deep_equal(lines, new) then
    return true, ("%s palette already matches the %s theme"):format(path, theme), warnings
  end

  if mode == "write" then
    vim.fn.writefile(new, path)
    return true, ("%s palette regenerated from the %s theme"):format(path, theme), warnings
  end

  -- Check mode: report the drift rather than a bare "stale".
  local changed = {}
  for i = 1, math.max(#lines, #new) do
    if lines[i] ~= new[i] then
      changed[#changed + 1] = ("  line %d: %s -> %s"):format(i, tostring(lines[i]), tostring(new[i]))
    end
  end
  return false, ("%s palette is stale:\n%s"):format(path, table.concat(changed, "\n")), warnings
end

return M
