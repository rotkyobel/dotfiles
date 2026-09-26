-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Pin LazyVim's library choices explicitly. LazyVim swaps these defaults
-- between releases; naming them here means an upstream default change cannot
-- silently replace the picker or completion engine under this config.
vim.g.lazyvim_picker = "snacks"
vim.g.lazyvim_cmp = "blink.cmp"

-- Only run prettier when the project actually has a prettier config. Without
-- this, opening a file in a repo that uses a different style gets rewritten.
vim.g.lazyvim_prettier_needs_config = true
