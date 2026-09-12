return {
  -- LazyVim ships catppuccin, so only the flavour and the palette overrides
  -- for the "Catppuccin Espresso" Ghostty theme are declared here. Everything
  -- else (integrations, undercurls) is inherited from LazyVim's spec.
  {
    "catppuccin/nvim",
    opts = {
      flavour = "macchiato",
      transparent_background = true,
      color_overrides = {
        macchiato = {
          -- ~/.config/ghostty/themes/Catppuccin Espresso
          base = "#0a0a0a",
          mantle = "#0a0a0a",
          crust = "#0a0a0a",
        },
      },
    },
  },

  -- The active colorscheme is chosen at startup by lua/bscenez/theme.lua so
  -- that Neovim follows whichever Ghostty theme is selected. tokyonight is
  -- never applied, so it is not installed at all.
  { "folke/tokyonight.nvim", enabled = false },
}
