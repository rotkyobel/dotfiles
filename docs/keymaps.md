# Keymaps

Only the keymaps this config adds or changes are listed here. LazyVim provides a
large default set that is not duplicated below — see `:LazyVim` or the
[LazyVim keymaps reference](https://lazyvim.github.io/Keymaps).

Leader is `Space`, local leader is `\`.

## This config

| Key | Mode | Action | Source |
| --- | --- | --- | --- |
| `<leader>ct` | n | Re-apply the Ghostty theme | `lua/config/keymaps.lua` |
| `dd(...)` | — | Dump a value in a floating notification | `init.lua` |
| `<localleader>d` | n | Dump the plugin spec under the cursor (inside `:Lazy`) | `lua/config/lazy.lua` |

## Theme

| Key / command | Action |
| --- | --- |
| `<leader>ct` | Re-apply the theme after toggling it in Ghostty (ctrl+shift+y) |
| `:ThemeSync` | Same as above |

Saving `~/.config/ghostty/config` from inside Neovim also re-applies it.

## Editing

From `editor.dial` (LazyVim extra):

| Key | Mode | Action |
| --- | --- | --- |
| `<C-a>` / `<C-x>` | n, v | Increment / decrement — numbers, hex, dates, weekdays, months, `true`/`false`, `&&`/`\|\|`, semver (in JSON), `[ ]`/`[x]` (in markdown), hex colors (in CSS) |
| `g<C-a>` / `g<C-x>` | n, x | Increment / decrement sequentially across a selection |

From `editor.inc-rename` (LazyVim extra), buffer-local once an LSP client
attaches:

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>cr` | n | Rename symbol with inline preview |

## Bracketed navigation

From `mini.bracketed` (`lua/plugins/coding.lua`). The `file`, `window`,
`quickfix` and `yank` categories are disabled there, as LazyVim already covers
quickfix and window movement.

| Key | Action |
| --- | --- |
| `[b` / `]b` | Previous / next buffer |
| `[c` / `]c` | Previous / next comment |
| `[d` / `]d` | Previous / next diagnostic |
| `[e` / `]e` | Previous / next error |
| `[w` / `]w` | Previous / next warning |
| `[i` / `]i` | Previous / next indent change |
| `[I` / `]I` | First / last indent change |
| `[j` / `]j` | Previous / next jump (jumplist) |
| `[J` / `]J` | First / last jump |
| `[l` / `]l` | Previous / next location (location list) |
| `[L` / `]L` | First / last location |
| `[n` / `]n` | Previous / next treesitter node |
| `[N` / `]N` | First / last treesitter node |
| `[o` / `]o` | Previous / next old file |
| `[O` / `]O` | First / last old file |
| `[u` / `]u` | Previous / next undo state |
| `[U` / `]U` | First / last undo state |
| `[x` / `]x` | Previous / next conflict marker |
| `[X` / `]X` | First / last conflict |
| `[q` / `]q` | Previous / next quickfix entry |
| `[t` / `]t` | Previous / next todo comment |
| `[<C-L>` / `]<C-L>` | Previous / next file in the location list |
| `[<C-Q>` / `]<C-Q>` | Previous / next file in the quickfix list |
| `[<C-T>` / `]<C-T>` | Previous / next tag |

## UI

| Key | Action | Source |
| --- | --- | --- |
| `<leader>uz` | Toggle zen mode | LazyVim built-in (`Snacks.zen`) |
| `<leader>cm` | Open Mason | LazyVim built-in |
| `<leader>cf` | Format buffer | LazyVim built-in |

## Commands

| Command | Action |
| --- | --- |
| `:ThemeSync` | Re-apply the Ghostty theme |
| `:Lazy` | Plugin manager (`<localleader>d` dumps the selected plugin's spec) |
| `:LazyExtras` | Browse extras — see the README for why they live in `lazy.lua` |
| `:Mason` | Manage LSP servers and tools |
| `:checkhealth` | Health check (`:LazyHealth` loads everything first) |
| `:InspectTree` / `:EditQuery` | Treesitter inspector — replaces the archived `playground` plugin |
| `:ConformInfo` | Formatter info for the current buffer |

## Debug

| Call | Action |
| --- | --- |
| `dd(value)` | Dump a value in a floating, lua-highlighted notification |
| `vim.print(value)` | Same rendering, still returns its arguments |
| `require("bscenez.debug").extmark_leaks()` | Namespaces holding extmarks in live buffers, largest first |
| `require("bscenez.debug").module_leaks()` | Approximate memory per loaded lua module |
| `require("bscenez.debug").get_loc()` | Source location of the caller |
