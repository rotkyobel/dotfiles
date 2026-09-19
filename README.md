# Claude config

    CLAUDE.md         Global preferences (commit style, comment density).
                      Applies everywhere; a project's own CLAUDE.md composes
                      on top and wins locally.
    settings.json     Harness config, 7 keys. No hooks; `statusLine` is the
                      only entry pointing at a script — no inline shell.
    statusline/
      render.sh       statusLine entry point. The visible two rows:
                      ╭─ ◆ dir · model · effort · lines
                      ╰─ branch dirty ahead · context bar used/size
    skills/           Symlinks only. The real skills live in
                      ~/.agents/skills, installed with the `skills` CLI
                      (lockfile: ~/.agents/.skill-lock.json). Two kept:
                      improve (shadcn), frontend-design (anthropics).
      synced/         Account-synced Anthropic skills (docs, docx, pdf, pptx,
                      xlsx, morning, skill-creator, import-memory). Managed
                      remotely — not ours to edit. Same for plugins/synced/.

## Statusline legend

Row 1

    ◆ 󰉋 path      teal ◆, blue path. Collapses past 30 chars:
                  ~/Coding/Projects/essalud/raaus → ~/Coding/.../raaus
    model         mauve. "(1M context)" is stripped — the window size
                  already shows on row 2 as 620k/1.0M.
    󰓅 effort      teal. Absent when the payload carries no effort level.
    +120 −30      green added, red removed, session totals. Absent when
                  both are zero.

Row 2 — git

    󰘬 branch      green      current branch; "detached" when headless
    ●13           peach      13 dirty files — modified, staged, renamed,
                             unmerged and untracked all count
    ↑7            blue       7 commits ahead of upstream
    ↓2            red        2 commits behind upstream
    ○ no repo     dim grey   cwd is not inside a git worktree

    The three counters are independent and each disappears at zero, so a
    clean branch in sync with its upstream shows the branch name alone.
    All of it comes from one `git status --porcelain=v2 --branch` call —
    separate invocations for branch, divergence and dirty state were
    noticeable on every keystroke.

Row 2 — context

    󰔟 62% ▰▰▰▰▱▱  6-cell bar, rounded up so a live-but-tiny context still
                  lights one cell; only a true 0% leaves it empty
    620k/1.0M     dim grey, tokens used over window size

    Percentage and bar share one colour, by threshold:

    green  #a6e3a1   under 50%
    peach  #fab387   50–79%
    red    #f38ba8   80% and up

Palette is Catppuccin Mocha throughout; the same peach and red do double duty
as "dirty" and "behind" on the git side.

Spacing: segments are joined by `   ·   ` (three spaces each side); the git
counters and the used/size figure sit two spaces from their neighbour. Nerd
Font glyphs render wider than a cell, so each gets two spaces before its
value; `●` `↑` `↓` get one. Do not tighten any of this.

One MCP server, `context7`, is configured globally in `~/.claude.json`, not
here — `settings.json` never carries it.

Everything else in this directory is runtime state, not config: `backups/`
`cache/` `file-history/` `image-cache/` `paste-cache/` `projects/`
`session-env/` `sessions/` `shell-snapshots/` `history.jsonl`

## What this repo tracks

`.gitignore` is an allowlist. Six files are versioned — this README, the two
config files, the statusline script, the ignore file and `.gitattributes`. Everything else
here is runtime state Claude Code owns: session transcripts under `projects/`,
`history.jsonl`, the caches, `sessions/`, `shell-snapshots/`, `telemetry/`, and
the account-synced `skills/synced` and `plugins/synced`. The transcripts and the
per-project memory files under `projects/*/memory/` carry client work and stay
out of git regardless of how the repo is hosted.

On Windows only `CLAUDE.md` and the ignore rules carry over unchanged.
`statusline/render.sh` needs bash plus `jq`, so it runs under WSL or Git Bash
but not cmd or PowerShell, and the `statusLine` command in `settings.json`
points at it with a `$HOME` path that neither Windows shell expands — override
that key locally there. `.gitattributes` pins the script to LF so at least the
line endings are not a third surprise.

Two things live outside this directory and are not captured here:

- The skills in `~/.agents/skills` (see above) — reinstall them with the
  `skills` CLI, then symlink each into `skills/`.
- MCP servers in `~/.claude.json` — re-add `context7` with `claude mcp add`.
  Its API key is not in this repo and must be supplied again.

## Notes

- `settings.json` has no `hooks` key at all. Removed three times now: Orca's
  12 inline entries, unpeel's 5, then unpeel's 7 again after a reinstall
  (2026-09-17) — that round also left a dead `unpeel` MCP server in
  `~/.claude.json` whose launcher pointed at an app already in the Trash, so
  every session opened with a CONNECTION_CLOSED error. Uninstalling either tool
  from its own UI does not clean up after itself; check both files afterwards.
  If Orca is ever reinstalled it will re-add its own blob, and that blob is
  best left alone — extracting it to a shared script made Orca's next update
  fail to recognise it as installed, re-add the blob alongside, and fire every
  event twice.
- `statusline/render.sh` is framed on the left only (`╭─` / `╰─`) and reads no
  terminal width. Claude Code captures the script's stdout, so `tput`/ioctl see
  no terminal, and the width it passes goes stale on resize — every earlier
  version that drew a right edge ended up either truncated to `…` or stopping
  short of the margin. Do not reintroduce right-justification or a full box.
- The other in-place comment there: tab is IFS whitespace, so jq fields are
  joined with `0x1f`, otherwise an empty middle field shifts every later one
  left.
- `settings.json` had a generated `autoMode.environment` block (3.7K of
  security context about one project's prod paths and internal hosts). Removed
  along with the rest; Claude Code regenerates it if auto mode is turned back
  on.
- MCP servers live in `~/.claude.json`, never in `settings.json`. Remove one
  with `claude mcp remove <name> -s user` rather than editing the file by hand;
  Claude Code rewrites that file on its own schedule and will clobber a manual
  edit. `context7` is the only entry, and it carries an API key in plaintext.
- `~/.claude.json` is runtime state, not config, but it accumulates: it tracks
  every directory Claude Code has run in. Entries whose path no longer exists
  are safe to drop — trust-dialog acceptance and allowed tools go with them,
  which only matters for paths that still exist.
