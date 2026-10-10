-- Deep Tide
--
-- A Neovim colorscheme generated from the Ghostty theme of the same name so
-- the editor and the terminal stay exactly in sync.
--
-- Palette source: ~/.config/ghostty/themes/Deep Tide
-- Regenerate this file if that theme changes.
--
-- Backgrounds are deliberately left transparent so Ghostty's window opacity
-- and blur show through.

vim.cmd("hi clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end

vim.o.termguicolors = true
vim.g.colors_name = "deep_tide"

local c = {
  none = "NONE",
  bg = "#010608",
  fg = "#d7f4fc",
  black = "#061215",
  red = "#ff7a90",
  green = "#8ff0c7",
  yellow = "#facc6b",
  blue = "#74b9ff",
  magenta = "#c084fc",
  cyan = "#16cfe4",
  white = "#b8d6de",
  bright_black = "#567d87",
  bright_red = "#ff96a8",
  bright_green = "#a7f8d8",
  bright_yellow = "#ffe08a",
  bright_blue = "#93caff",
  bright_magenta = "#d8b4fe",
  bright_cyan = "#77e4ff",
  bright_white = "#f0fcff",
  cursor = "#78e4ff",
  selection = "#13333c",
  -- surfaces: no Ghostty equivalent, hand-tuned (see lua/bscenez/palette.lua)
  surface = "#0a1519",
  surface_alt = "#0d1f25",
  -- diff backgrounds, tinted from green / blue / red
  diff_add = "#0d2a1f",
  diff_change = "#0d2430",
  diff_delete = "#2a1220",
}

---@param group string
---@param opts vim.api.keyset.highlight
local function set(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

---@param groups table<string, string|table>
local function link(groups)
  for from, to in pairs(groups) do
    set(from, { link = to })
  end
end

-- Editor UI ----------------------------------------------------------------

set("Normal", { fg = c.fg, bg = c.none })
set("NormalNC", { fg = c.fg, bg = c.none })
set("NormalFloat", { fg = c.fg, bg = c.none })
set("FloatBorder", { fg = c.selection, bg = c.none })
set("FloatTitle", { fg = c.bright_cyan, bg = c.none, bold = true })
set("Cursor", { fg = c.bg, bg = c.cursor })
set("CursorLine", { bg = c.surface })
set("CursorColumn", { bg = c.surface })
set("CursorLineNr", { fg = c.yellow, bold = true })
set("LineNr", { fg = c.bright_black })
set("ColorColumn", { bg = c.surface })
set("SignColumn", { bg = c.none })
set("Folded", { fg = c.bright_blue, bg = c.surface })
set("FoldColumn", { fg = c.bright_black, bg = c.none })
set("EndOfBuffer", { fg = c.none, bg = c.none })
set("NonText", { fg = c.bright_black })
set("SpecialKey", { fg = c.bright_black })
set("Whitespace", { fg = c.bright_black })
set("Visual", { bg = c.selection })
set("VisualNOS", { bg = c.selection })
set("Search", { fg = c.bright_white, bg = c.selection })
set("IncSearch", { fg = c.bg, bg = c.bright_cyan })
set("MatchParen", { fg = c.bright_yellow, bold = true, underline = true })

set("Pmenu", { fg = c.fg, bg = c.surface })
set("PmenuSel", { fg = c.bright_white, bg = c.selection, bold = true })
set("PmenuSbar", { bg = c.surface_alt })
set("PmenuThumb", { bg = c.bright_black })
set("PmenuKind", { fg = c.bright_cyan, bg = c.surface })
set("PmenuKindSel", { fg = c.bright_cyan, bg = c.selection })
set("PmenuExtra", { fg = c.bright_black, bg = c.surface })
set("PmenuExtraSel", { fg = c.white, bg = c.selection })

set("StatusLine", { fg = c.white, bg = c.black })
set("StatusLineNC", { fg = c.bright_black, bg = c.black })
set("TabLine", { fg = c.bright_black, bg = c.black })
set("TabLineFill", { bg = c.black })
set("TabLineSel", { fg = c.bright_cyan, bg = c.surface, bold = true })
set("WinSeparator", { fg = c.selection, bg = c.none })

set("Title", { fg = c.bright_cyan, bold = true })
set("Directory", { fg = c.blue })
set("Question", { fg = c.green })
set("MoreMsg", { fg = c.green })
set("ModeMsg", { fg = c.bright_white, bold = true })
set("WarningMsg", { fg = c.yellow })
set("ErrorMsg", { fg = c.red })
set("QuickFixLine", { bg = c.selection })
set("Conceal", { fg = c.bright_black })
set("CursorIM", { fg = c.bg, bg = c.cursor })

set("SpellBad", { undercurl = true, sp = c.red })
set("SpellCap", { undercurl = true, sp = c.yellow })
set("SpellLocal", { undercurl = true, sp = c.cyan })
set("SpellRare", { undercurl = true, sp = c.magenta })

-- Syntax -------------------------------------------------------------------

set("Comment", { fg = c.bright_black, italic = true })
set("Constant", { fg = c.yellow })
set("String", { fg = c.green })
set("Number", { fg = c.yellow })
set("Boolean", { fg = c.yellow })
set("Identifier", { fg = c.fg })
set("Function", { fg = c.blue })
set("Statement", { fg = c.magenta })
set("Operator", { fg = c.cyan })
set("Keyword", { fg = c.magenta })
set("PreProc", { fg = c.bright_cyan })
set("Type", { fg = c.bright_cyan })
set("StorageClass", { fg = c.bright_cyan })
set("Structure", { fg = c.bright_cyan })
set("Special", { fg = c.bright_blue })
set("Delimiter", { fg = c.white })
set("SpecialComment", { fg = c.bright_black, italic = true })
set("Debug", { fg = c.bright_red })
set("Underlined", { underline = true })
set("Bold", { bold = true })
set("Italic", { italic = true })
set("Ignore", { fg = c.bright_black })
set("Error", { fg = c.red })
set("Todo", { fg = c.bg, bg = c.yellow, bold = true })

link({
  Character = "String",
  Float = "Number",
  Conditional = "Statement",
  Repeat = "Statement",
  Label = "Statement",
  Exception = "Statement",
  Include = "PreProc",
  Define = "PreProc",
  Macro = "PreProc",
  PreCondit = "PreProc",
  Typedef = "Type",
  SpecialChar = "Special",
  Tag = "Special",
})

-- Treesitter captures ------------------------------------------------------

local treesitter = {
  ["@variable"] = { fg = c.fg },
  ["@variable.builtin"] = { fg = c.bright_magenta, italic = true },
  ["@variable.parameter"] = { fg = c.white },
  ["@variable.member"] = { fg = c.bright_blue },
  ["@constant"] = { fg = c.yellow },
  ["@constant.builtin"] = { fg = c.yellow },
  ["@constant.macro"] = { fg = c.bright_cyan },
  ["@module"] = { fg = c.bright_cyan },
  ["@module.builtin"] = { fg = c.bright_magenta, italic = true },
  ["@string"] = { fg = c.green },
  ["@string.escape"] = { fg = c.bright_green },
  ["@string.regexp"] = { fg = c.bright_green },
  ["@string.special"] = { fg = c.bright_green },
  ["@number"] = { fg = c.yellow },
  ["@number.float"] = { fg = c.yellow },
  ["@boolean"] = { fg = c.yellow },
  ["@function"] = { fg = c.blue },
  ["@function.builtin"] = { fg = c.bright_blue, italic = true },
  ["@function.call"] = { fg = c.blue },
  ["@function.macro"] = { fg = c.bright_cyan },
  ["@function.method"] = { fg = c.blue },
  ["@function.method.call"] = { fg = c.blue },
  ["@constructor"] = { fg = c.bright_cyan },
  ["@keyword"] = { fg = c.magenta },
  ["@keyword.function"] = { fg = c.magenta },
  ["@keyword.operator"] = { fg = c.cyan },
  ["@keyword.import"] = { fg = c.magenta },
  ["@keyword.return"] = { fg = c.magenta },
  ["@keyword.conditional"] = { fg = c.magenta },
  ["@keyword.repeat"] = { fg = c.magenta },
  ["@keyword.type"] = { fg = c.magenta },
  ["@keyword.exception"] = { fg = c.magenta },
  ["@operator"] = { fg = c.cyan },
  ["@type"] = { fg = c.bright_cyan },
  ["@type.builtin"] = { fg = c.bright_cyan, italic = true },
  ["@type.qualifier"] = { fg = c.magenta },
  ["@type.definition"] = { fg = c.bright_cyan },
  ["@property"] = { fg = c.bright_blue },
  ["@field"] = { fg = c.bright_blue },
  ["@attribute"] = { fg = c.bright_cyan },
  ["@label"] = { fg = c.magenta },
  ["@namespace"] = { fg = c.bright_cyan },
  ["@tag"] = { fg = c.magenta },
  ["@tag.attribute"] = { fg = c.bright_blue },
  ["@tag.delimiter"] = { fg = c.white },
  ["@punctuation"] = { fg = c.white },
  ["@punctuation.delimiter"] = { fg = c.white },
  ["@punctuation.bracket"] = { fg = c.white },
  ["@punctuation.special"] = { fg = c.cyan },
  ["@comment"] = { fg = c.bright_black, italic = true },
  ["@comment.error"] = { fg = c.bg, bg = c.red },
  ["@comment.warning"] = { fg = c.bg, bg = c.yellow },
  ["@comment.todo"] = { fg = c.bg, bg = c.cyan },
  ["@comment.note"] = { fg = c.bg, bg = c.blue },
  ["@diff.plus"] = { fg = c.green },
  ["@diff.minus"] = { fg = c.red },
  ["@diff.delta"] = { fg = c.bright_black },
  ["@markup.heading"] = { fg = c.bright_cyan, bold = true },
  ["@markup.heading.1"] = { fg = c.bright_cyan, bold = true },
  ["@markup.heading.2"] = { fg = c.blue, bold = true },
  ["@markup.heading.3"] = { fg = c.green, bold = true },
  ["@markup.link"] = { fg = c.blue },
  ["@markup.link.url"] = { fg = c.blue, underline = true },
  ["@markup.link.label"] = { fg = c.bright_cyan },
  ["@markup.raw"] = { fg = c.green },
  ["@markup.raw.block"] = { fg = c.green },
  ["@markup.italic"] = { italic = true },
  ["@markup.bold"] = { bold = true },
  ["@markup.strikethrough"] = { strikethrough = true },
  ["@markup.list"] = { fg = c.bright_cyan },
  ["@markup.quote"] = { fg = c.bright_black, italic = true },
}

for group, opts in pairs(treesitter) do
  set(group, opts)
end

-- LSP semantic tokens ------------------------------------------------------

link({
  ["@lsp.type.class"] = "Type",
  ["@lsp.type.enum"] = "Type",
  ["@lsp.type.enumMember"] = "Constant",
  ["@lsp.type.interface"] = "Type",
  ["@lsp.type.struct"] = "Type",
  ["@lsp.type.typeParameter"] = "Type",
  ["@lsp.type.parameter"] = "@variable.parameter",
  ["@lsp.type.property"] = "@property",
  ["@lsp.type.function"] = "@function",
  ["@lsp.type.method"] = "@function.method",
  ["@lsp.type.variable"] = "@variable",
  ["@lsp.type.namespace"] = "@namespace",
  ["@lsp.type.keyword"] = "@keyword",
  ["@lsp.type.comment"] = "@comment",
  ["@lsp.type.string"] = "@string",
  ["@lsp.type.number"] = "@number",
  ["@lsp.type.operator"] = "@operator",
  ["@lsp.type.macro"] = "@function.macro",
  ["@lsp.type.decorator"] = "@attribute",
  ["@lsp.type.event"] = "Type",
})

-- Diagnostics --------------------------------------------------------------

set("LspReferenceText", { bg = c.surface_alt })
set("LspReferenceRead", { bg = c.surface_alt })
set("LspReferenceWrite", { bg = c.surface_alt, underline = true })
set("LspSignatureActiveParameter", { fg = c.bright_yellow, bold = true })

set("DiagnosticError", { fg = c.red })
set("DiagnosticWarn", { fg = c.yellow })
set("DiagnosticInfo", { fg = c.blue })
set("DiagnosticHint", { fg = c.cyan })
set("DiagnosticOk", { fg = c.green })
set("DiagnosticVirtualTextError", { fg = c.red, bg = c.none })
set("DiagnosticVirtualTextWarn", { fg = c.yellow, bg = c.none })
set("DiagnosticVirtualTextInfo", { fg = c.blue, bg = c.none })
set("DiagnosticVirtualTextHint", { fg = c.cyan, bg = c.none })
set("DiagnosticVirtualTextOk", { fg = c.green, bg = c.none })
set("DiagnosticUnderlineError", { undercurl = true, sp = c.red })
set("DiagnosticUnderlineWarn", { undercurl = true, sp = c.yellow })
set("DiagnosticUnderlineInfo", { undercurl = true, sp = c.blue })
set("DiagnosticUnderlineHint", { undercurl = true, sp = c.cyan })
set("DiagnosticUnderlineOk", { undercurl = true, sp = c.green })

-- Diffs and git ------------------------------------------------------------

set("DiffAdd", { bg = c.diff_add })
set("DiffChange", { bg = c.diff_change })
set("DiffDelete", { bg = c.diff_delete })
set("DiffText", { bg = c.selection })
set("Added", { fg = c.green })
set("Changed", { fg = c.yellow })
set("Removed", { fg = c.red })

set("GitSignsAdd", { fg = c.green })
set("GitSignsChange", { fg = c.yellow })
set("GitSignsDelete", { fg = c.red })
set("GitSignsAddInline", { bg = c.diff_add })
set("GitSignsChangeInline", { bg = c.diff_change })
set("GitSignsDeleteInline", { bg = c.diff_delete })

-- Terminal colors ----------------------------------------------------------

local terminal = {
  c.black,
  c.red,
  c.green,
  c.yellow,
  c.blue,
  c.magenta,
  c.cyan,
  c.white,
  c.bright_black,
  c.bright_red,
  c.bright_green,
  c.bright_yellow,
  c.bright_blue,
  c.bright_magenta,
  c.bright_cyan,
  c.bright_white,
}

for i, color in ipairs(terminal) do
  vim.g["terminal_color_" .. (i - 1)] = color
end
