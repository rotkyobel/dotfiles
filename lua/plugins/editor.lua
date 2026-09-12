return {
  -- Render color values inline: hex, rgb(), hsl(), ansi variables and tailwind
  -- palette classes. Handy for reviewing palette-driven UI work.
  {
    "brenoprata10/nvim-highlight-colors",
    event = "BufReadPre",
    opts = {
      -- Switch to "foreground" if coloring the background behind the literal
      -- feels too loud.
      render = "background",
      enable_hex = true,
      enable_short_hex = true,
      enable_rgb = true,
      enable_hsl = true,
      enable_hsl_without_function = true,
      enable_ansi = true,
      enable_var_usage = true,
      enable_tailwind = true,
    },
  },
}
