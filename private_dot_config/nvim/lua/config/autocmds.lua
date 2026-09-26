-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Saving the Ghostty config from inside Neovim re-applies the matching theme,
-- so editing it here does not leave the two out of sync until the next restart.
vim.api.nvim_create_autocmd("BufWritePost", {
  group = vim.api.nvim_create_augroup("BscenezThemeSync", { clear = true }),
  pattern = { "*/ghostty/config" },
  callback = function()
    require("bscenez.theme").sync()
  end,
})
