# Global preferences

## Commits

- Never add a `Co-Authored-By: Claude` trailer, a "Generated with Claude Code"
  line, or any other Claude/Anthropic attribution — not in commit messages, not
  in PR bodies.
- Keep messages concise. A subject line alone is right for most changes. Add a
  body only to explain a *why* the diff cannot show; never to restate what
  changed.
- Read `git log --oneline -10` before writing, and match what is already there:
  language, prefix convention, scope style, capitalization, tense. Never mix
  languages within a repo.

## Code comments

- Comment sparingly. Most code should carry none.
- Write one only where the code cannot speak for itself: a non-obvious *why*, a
  workaround, a constraint or gotcha that would otherwise be re-broken later.
- Never narrate what the code plainly does. Code being new is not a reason to
  comment it.
- Keep each comment short and direct: one line where possible, plain words,
  no restating context the reader already has from the code around it.
- Docstrings and JSDoc count as comments: add them only where the file already
  uses them.
- Match the comment density and language of the surrounding file.
