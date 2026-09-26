# dotfiles

Managed with [chezmoi](https://chezmoi.io). Files are copied into place, not
symlinked.

    dot_zshrc                      zsh (no framework: starship, mise, fzf, zoxide)
    private_dot_config/
      ghostty/                     terminal config, themes, theme toggle
      starship.toml                prompt
      nvim/                        LazyVim-based Neovim config
      herdr/config.toml
    private_dot_claude/            Claude Code settings, rules, statusline
                                   (see private_dot_claude/README.md)

## New machine

macOS / Linux:

    sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply rotkyobel

Windows (PowerShell):

    winget install twpayne.chezmoi
    chezmoi init --apply rotkyobel

On Windows, zsh, ghostty and herdr are skipped (`.chezmoiignore`), and a
one-time script sets `XDG_CONFIG_HOME` to `~\.config` so Neovim reads the same
config path as everywhere else. That variable also moves where other
XDG-aware tools like `gh` look for config.

## Day to day

    chezmoi edit ~/.zshrc     edit the source copy, then `chezmoi apply`
    chezmoi re-add            pull changes made directly in ~ back in
    chezmoi diff              what apply would change
    chezmoi cd                open a shell in this repo to commit and push
    chezmoi update            pull and apply on another machine

Ghostty's theme toggle and Claude Code both rewrite their own files, so
expect `chezmoi diff` to show drift there; `re-add` to keep it.
