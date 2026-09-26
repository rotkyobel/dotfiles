# Neovim config

Personal [LazyVim](https://lazyvim.github.io) setup, rebuilt from the starter.

Web-development focused (TypeScript / React / Tailwind), with the editor
colorscheme following whichever [Ghostty](https://ghostty.org) theme is active.

## Requirements

- Neovim >= 0.11.2 (LazyVim 16 minimum; developed against 0.12.5)
- `git`, `ripgrep`, `fd` (`fzf` and `lazygit` optional)
- Node.js — Mason installs the TypeScript, Tailwind, JSON, YAML and ESLint
  language servers via npm
- A Nerd Font for the icons

## Layout

| Path | Purpose |
| --- | --- |
| `init.lua` | Enables the lua loader, defines `dd`, hands off to `config.lazy` |
| `lua/config/lazy.lua` | lazy.nvim bootstrap, LazyVim import order, enabled extras |
| `lua/config/options.lua` | Options plus the LazyVim global pins |
| `lua/config/keymaps.lua` | Custom keymaps |
| `lua/config/autocmds.lua` | Custom autocmds |
| `lua/bscenez/theme.lua` | Reads the active Ghostty theme and applies the match |
| `lua/bscenez/debug.lua` | `dd()` dump helper and leak finders |
| `lua/plugins/*.lua` | Plugin overrides and additions |
| `colors/deep_tide.lua` | Standalone colorscheme generated from a Ghostty theme |
| `scripts/` | Maintenance and verification scripts (see Verification) |
| `docs/keymaps.md` | The keymaps this config adds or changes |

Personal modules live under `lua/bscenez/` so they never collide with LazyVim's
own `lua/lazyvim/` or with plugin specs.

## Theme

The colorscheme follows `theme = <name>` in `~/.config/ghostty/config`:

| Ghostty theme | Neovim colorscheme | Notes |
| --- | --- | --- |
| `Catppuccin Espresso` | `catppuccin-macchiato` | `#0a0a0a` surfaces via `color_overrides` in `lua/plugins/theme.lua` |
| `Deep Tide` | `deep_tide` | `colors/deep_tide.lua`, generated from the Ghostty palette |

Anything else falls back to `Catppuccin Espresso` with a warning.

Backgrounds are deliberately left transparent (`Normal`, `NormalFloat`,
`FloatBorder`, `FloatTitle`, `SignColumn`, `EndOfBuffer`) so Ghostty's window
opacity and blur show through.

Ghostty rewrites its config in place when you toggle a theme and reloads itself;
Neovim cannot observe that, so re-apply with any of:

- `<leader>ct`
- `:ThemeSync`
- save `~/.config/ghostty/config` from inside Neovim (BufWritePost autocmd)

### Adding a third theme

1. Drop a palette file in `~/.config/ghostty/themes/`.
2. Add an entry to `M.themes` in `lua/bscenez/theme.lua`.
3. If it needs an accent color for UI plugins, add one to `M.ui`.

For a bespoke palette, copy `colors/deep_tide.lua` and regenerate the values.

## LazyVim extras in use

Web development only:

```text
lang.typescript  lang.tailwind  lang.json  lang.yaml  lang.markdown
linting.eslint   formatting.prettier
editor.dial      editor.inc-rename
```

Extras are declared explicitly in `lua/config/lazy.lua`, not in `lazyvim.json`.
LazyVim checks the spec's imported modules first and `lazyvim.json` second, so
declaring them as imports keeps them under version control and avoids the
confusing state where `:LazyExtras` toggles something the spec still imports.
For the same reason `lazyvim.json` is gitignored: it only holds machine state
(news version, install marker).

`lang.typescript` resolves its server through LazyVim's `ts_lsp` registry and
defaults to **vtsls**.

## Plugin updates

`checker.enabled = false` in `lua/config/lazy.lua` — update checks are off on
purpose, because every plugin is pinned by commit in `lazy-lock.json` and
auto-updates would quietly make that file meaningless.

To update:

```sh
nvim --headless "+Lazy! update" +qa
# then verify and commit
git diff lazy-lock.json
```

## Verification

Scripts live in `scripts/` and take no arguments:

```sh
# plugins
nvim -i NONE --headless "+Lazy! sync" +qa

# then install anything Mason did not finish (safe to re-run)
nvim -i NONE --headless -c "luafile scripts/mason-sync.lua" -c "qa!"

# which LSP servers are enabled, and are their Mason packages present?
nvim -i NONE --headless -c "luafile scripts/lsp-status.lua" -c "qa!"

# full functional pass: theme, transparency, keymaps, treesitter, LSP attach
nvim -i NONE --headless -c "luafile scripts/verify.lua" -c "qa!"
cat /tmp/bscenez-verify.txt
```

`verify.lua` always exits 0, because Neovim does; read the report, which ends
with a `N checks, M failed` line.

## Gotchas

Learned the hard way, worth keeping in mind:

- **Headless `Lazy! sync` aborts Mason installs.** Neovim exits while packages
  are still installing. Install them explicitly afterwards and wait for Mason's
  `install:success` event; do not assume `is_installed()` means the files landed.
- **`vim.fn.executable()` returns 1 for a dangling symlink.** Mason creates the
  `mason/bin/<name>` symlink early, so waiting on it exits before npm finishes.
  Use `vim.uv.fs_stat()`, which follows symlinks.
- **`VeryLazy` does not fire under `--headless`.** LazyVim's own keymaps and
  lazy-loaded plugin setup are missing there, which makes verification scripts
  report false failures. Trigger it explicitly, or verify in a real pty.
- **LSP enablement depends on the Mason package existing.** LazyVim hands
  `mason-lspconfig` an `automatic_enable` list, and a server whose package is
  absent is silently not enabled — no error, just no client.
- **lazy.nvim merges only `opts`, `cmd`, `event`, `ft` and `keys` between specs.**
  Defining your own `config` for a plugin *replaces* LazyVim's, which is how you
  lose treesitter highlighting without any error. Prefer `opts` overrides.
- `require("lazyvim.util")` still resolves, but it is the compatibility path;
  use the `LazyVim` global in new code.

## Debug helpers

```lua
dd(some_table)                          -- floating, lua-highlighted dump
require("bscenez.debug").extmark_leaks() -- namespaces holding extmarks
require("bscenez.debug").module_leaks()  -- memory per loaded module
```

`vim.print` is routed through the same renderer but still returns its arguments.
Pressing `<localleader>d` on a plugin inside the `:Lazy` window dumps its spec.
