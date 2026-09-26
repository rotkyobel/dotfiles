-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Re-apply the Ghostty theme after toggling it (ctrl+shift+y in Ghostty).
-- Ghostty rewrites ~/.config/ghostty/config in place and signals its own
-- reload, so Neovim cannot detect the change and has to be told.
vim.keymap.set("n", "<leader>ct", function()
  require("bscenez.theme").sync()
end, { desc = "Re-sync Ghostty theme" })
