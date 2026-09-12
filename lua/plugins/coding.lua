return {
  -- Jump around with [ and ] across files, windows, buffers, diagnostics,
  -- quickfix entries, yanks, treesitter nodes and more.
  {
    "nvim-mini/mini.bracketed",
    event = "BufReadPost",
    opts = {
      -- Drop the default "b" suffix so the mappings stay short.
      file = { suffix = "" },
      window = { suffix = "" },
      quickfix = { suffix = "" },
      yank = { suffix = "" },
      treesitter = { suffix = "n" },
    },
  },
}
