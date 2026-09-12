return {
  -- Floating filename in the corner of the current window, so the file you are
  -- editing stays visible without a full statusline per split.
  {
    "b0o/incline.nvim",
    event = "BufReadPre",
    priority = 1200,
    opts = function()
      local ui = require("bscenez.theme").ui_colors()

      ---@param buf number
      ---@return string, string?
      local function icon(buf)
        local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t")
        -- Snacks ships with LazyVim and provides icons; degrade silently.
        local ok, ico, hl = pcall(Snacks.util.icon, filename)
        if ok and type(ico) == "string" and ico ~= "" then
          return ico, hl
        end
        return "", nil
      end

      return {
        window = { margin = { vertical = 0, horizontal = 1 } },
        hide = { cursorline = true },
        highlight = {
          groups = {
            InclineNormal = { bg = ui.accent, fg = ui.accent_fg, bold = true },
            InclineNormalNC = { fg = ui.accent, bg = ui.surface },
          },
        },
        render = function(props)
          local buf = props.buf
          local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t")
          if filename == "" then
            filename = "[No Name]"
          end

          local chunks = {}
          local ico, ico_hl = icon(buf)
          if ico ~= "" then
            chunks[#chunks + 1] = { ico .. " ", hl = ico_hl }
          end
          chunks[#chunks + 1] = { filename }
          if vim.bo[buf].modified then
            chunks[#chunks + 1] = { " ●" }
          end
          return chunks
        end,
      }
    end,
  },
}
