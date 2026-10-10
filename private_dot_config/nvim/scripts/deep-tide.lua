-- Regenerate the palette block in colors/deep_tide.lua from the Ghostty theme
-- of the same name.
--
--   # check only, never writes (the default)
--   nvim -i NONE --headless -c "luafile scripts/deep-tide.lua" -c "qa!"
--
--   # actually rewrite the palette
--   BSCENEZ_MODE=write nvim -i NONE --headless -c "luafile scripts/deep-tide.lua" -c "qa!"
--
-- Check-only by default because this rewrites a tracked source file: read the
-- report first, then opt in to the write. The hand-written highlight groups
-- below the palette are never touched, only the `local c = { ... }` block.
--
-- Only the palette is mechanical. The surfaces and diff tints have no Ghostty
-- equivalent and are hand-tuned; see lua/bscenez/palette.lua for why they are
-- constants and what guards them.

local THEME = "Deep Tide"
local root = vim.fn.stdpath("config")

local mode = vim.env.BSCENEZ_MODE or "check"
if mode ~= "check" and mode ~= "write" then
  print(("[deep-tide] BSCENEZ_MODE must be check or write, got %q; using check"):format(mode))
  mode = "check"
end

local palette = require("bscenez.palette")
local ok, message, warnings = palette.sync(THEME, root .. "/colors/deep_tide.lua", mode)

for _, warning in ipairs(warnings) do
  print("[deep-tide] warn: " .. warning)
end

print(("[deep-tide] %s"):format(message))
print(("[deep-tide] mode=%s result=%s"):format(mode, ok and "OK" or "FAIL"))
if not ok and mode == "check" then
  print("[deep-tide] re-run with BSCENEZ_MODE=write to apply")
end
