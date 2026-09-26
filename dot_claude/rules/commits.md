# Commits

- Never add a `Co-Authored-By: Claude` trailer, a "Generated with Claude Code"
  line, or any other Claude/Anthropic attribution — not in commit messages, not
  in PR bodies.
- Keep messages concise. A subject line alone is right for most changes. Add a
  body only to explain a *why* the diff cannot show; never to restate what
  changed.
- Read `git log --oneline -10` before writing, and match what is already there:
  language, prefix convention, scope style, capitalization, tense. Never mix
  languages within a repo.
