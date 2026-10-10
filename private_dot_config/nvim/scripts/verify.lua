-- Functional verification pass for this config: theme switching, transparency,
-- debug helpers, keymaps, plugin loading, treesitter highlighting, LSP attach on
-- a real TypeScript file, stylua formatting, and whether the generated
-- deep_tide palette still matches its Ghostty theme.
--
--   nvim -i NONE --headless -c "luafile scripts/verify.lua" -c "qa!"
--   cat /tmp/bscenez-verify.txt
--
-- Exit status is not meaningful (Neovim always exits 0 here); read the report.
-- VeryLazy does not fire under --headless, so the events LazyVim relies on are
-- triggered explicitly below. Without that, LazyVim's own keymaps and the lazy
-- plugin setup are missing and every check is a false negative.

local results = {}
local function check(name, ok, detail)
  results[#results + 1] = ("%s  %s%s"):format(ok and "PASS" or "FAIL", name, detail and ("  [" .. detail .. "]") or "")
end

local function finish()
  local failed = 0
  for _, line in ipairs(results) do
    if line:find("^FAIL") then
      failed = failed + 1
    end
  end
  local report = "===== VERIFY =====\n"
    .. table.concat(results, "\n")
    .. ("\n===== %d checks, %d failed =====\n"):format(#results, failed)
  vim.fn.writefile(vim.split(report, "\n"), "/tmp/bscenez-verify.txt")
  print(report)
  return failed
end

pcall(vim.cmd, "Lazy! load all")
vim.api.nvim_exec_autocmds("User", { pattern = "VeryLazy" })
vim.wait(4000, function()
  return false
end)

local ok_main, err_main = pcall(function()
  -- Theme -------------------------------------------------------------------
  local theme = require("bscenez.theme")
  check("theme reader finds Ghostty theme", theme.current() ~= nil, tostring(theme.current()))
  check("colorscheme matches the theme", vim.g.colors_name ~= nil, tostring(vim.g.colors_name))
  check("theme.active tracked", theme.active ~= nil, tostring(theme.active))

  local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
  check("Normal background is transparent", normal.bg == nil, "bg=" .. tostring(normal.bg))
  for _, group in ipairs({ "NormalFloat", "SignColumn", "EndOfBuffer" }) do
    local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
    check(group .. " background is transparent", hl.bg == nil, "bg=" .. tostring(hl.bg))
  end

  -- Deep Tide loads, and switching back restores the configured theme.
  local before = vim.g.colors_name
  local ok_dt = pcall(vim.cmd.colorscheme, "deep_tide")
  check("deep_tide colorscheme loads", ok_dt and vim.g.colors_name == "deep_tide", tostring(vim.g.colors_name))
  local dt_normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
  check("deep_tide Normal is transparent", dt_normal.bg == nil, "bg=" .. tostring(dt_normal.bg))
  local dt_keyword = vim.api.nvim_get_hl(0, { name = "Keyword", link = false })
  check("deep_tide Keyword is magenta", dt_keyword.fg == tonumber("c084fc", 16), "fg=" .. tostring(dt_keyword.fg))
  local dt_fn = vim.api.nvim_get_hl(0, { name = "@function", link = false })
  check("deep_tide defines treesitter captures", dt_fn.fg ~= nil, "fg=" .. tostring(dt_fn.fg))
  pcall(theme.apply)
  check("re-apply restores previous colorscheme", vim.g.colors_name == before, tostring(vim.g.colors_name))
  check("ThemeSync command exists", vim.fn.exists(":ThemeSync") == 2)

  -- Debug helpers -----------------------------------------------------------
  check("dd is a function", type(dd) == "function")
  check("debug.dump exists", type(require("bscenez.debug").dump) == "function")
  check("debug.extmark_leaks exists", type(require("bscenez.debug").extmark_leaks) == "function")
  check("debug.module_leaks exists", type(require("bscenez.debug").module_leaks) == "function")
  check("vim.print still returns values", select("#", vim.print("x")) == 1)
  check("debug.dump handles nil", pcall(require("bscenez.debug").dump, nil))
  check("debug.dump handles false", pcall(require("bscenez.debug").dump, false))

  -- Keymaps -----------------------------------------------------------------
  local maps = vim.api.nvim_get_keymap("n")
  local function has_map(lhs)
    for _, m in ipairs(maps) do
      if m.lhs == lhs then
        return true
      end
    end
    return false
  end
  -- leader is a literal space, so <leader>ct appears as " ct"
  check("keymap <leader>ct (theme re-sync)", has_map(" ct"))
  check("keymap <C-a> (dial increment)", has_map("<C-A>") or has_map("<C-a>"))
  check("keymap [b (mini.bracketed)", has_map("[b"))
  check("keymap <leader>uz (zen, built-in)", has_map(" uz"))

  -- Plugins -----------------------------------------------------------------
  -- dial.nvim exposes dial.map / dial.augend / dial.config, not a `dial` module.
  for _, mod in ipairs({ "mini.bracketed", "incline", "nvim-highlight-colors", "inc_rename", "dial.map", "dial.augend" }) do
    check("plugin loaded: " .. mod, (pcall(require, mod)))
  end
  check("tokyonight not loaded", package.loaded["tokyonight"] == nil)

  -- LSP + treesitter end-to-end --------------------------------------------
  local dir = "/tmp/bscenez-probe"
  vim.fn.mkdir(dir, "p")
  local file = dir .. "/probe.ts"
  vim.fn.writefile({
    'const greeting: string = "hi";',
    "export function shout(s: string) {",
    "  return s.toUpperCase();",
    "}",
  }, file)
  vim.cmd.edit(file)
  vim.wait(5000, function()
    return false
  end)

  local buf = vim.api.nvim_get_current_buf()
  check("filetype is typescript", vim.bo[buf].filetype == "typescript", vim.bo[buf].filetype)
  check("treesitter highlighter active", vim.treesitter.highlighter.active[buf] ~= nil)
  local parser_ok, parser = pcall(vim.treesitter.get_parser, buf)
  check("treesitter parser available", parser_ok and parser ~= nil)

  local attached = vim.wait(60000, function()
    return #vim.lsp.get_clients({ bufnr = buf }) > 0
  end, 500)
  local names = {}
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
    names[#names + 1] = client.name
  end
  check("LSP client attached to probe.ts", attached, table.concat(names, ","))

  -- <leader>cr from the inc-rename extra is a buffer-local LSP keymap, so it
  -- only exists once a client has attached.
  local has_buf_map = false
  for _, m in ipairs(vim.api.nvim_buf_get_keymap(buf, "n")) do
    if m.lhs == " cr" then
      has_buf_map = true
    end
  end
  check("buffer-local keymap <leader>cr (inc-rename)", has_buf_map)

  -- Formatting --------------------------------------------------------------
  -- stylua comes from Mason (LazyVim declares it in mason.nvim's
  -- ensure_installed), so it is normally not on the shell PATH.
  local root = vim.fn.stdpath("config")
  local stylua = vim.fn.stdpath("data") .. "/mason/bin/stylua"
  if vim.uv.fs_stat(stylua) == nil then
    stylua = vim.fn.exepath("stylua")
  end
  local have_stylua = vim.uv.fs_stat(stylua) ~= nil
  check("stylua available (mason or PATH)", have_stylua, have_stylua and stylua or "run scripts/mason-sync.lua")
  if have_stylua then
    local out = vim.fn.system({ stylua, "--check", root })
    local offenders = {}
    for path in out:gmatch("Diff in ([^\n]+)") do
      offenders[#offenders + 1] = (path:gsub("^%./", ""):gsub(":$", ""))
    end
    check("all lua files are stylua-formatted", vim.v.shell_error == 0, table.concat(offenders, " "))
  end

  -- Generated palette --------------------------------------------------------
  -- sync() in "check" mode is read-only, so calling it here has no side effect.
  local palette_ok, palette = pcall(require, "bscenez.palette")
  check("palette module loads", palette_ok)
  if palette_ok then
    local fresh, reason = palette.sync("Deep Tide", root .. "/colors/deep_tide.lua", "check")
    check(
      "deep_tide palette matches the Ghostty theme",
      fresh,
      fresh and "up to date" or (reason:gsub("\n.*", "") .. " -- run scripts/deep-tide.lua")
    )
  end
end)

if not ok_main then
  check("verification body completed", false, tostring(err_main))
end

finish()
vim.cmd("qa!")
