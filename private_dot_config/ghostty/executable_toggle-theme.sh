#!/usr/bin/env bash
# Cycle Ghostty through the themes in themes/ and live-reload via SIGUSR2.
set -euo pipefail

dir="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty"
config="$dir/config"

# macOS ships bash 3.2, so no mapfile; theme names contain spaces, so read line by line.
themes=()
while IFS= read -r t; do themes+=("$t"); done < <(
    find "$dir/themes" -maxdepth 1 -type f -exec basename {} \; | sort
)
(( ${#themes[@]} > 1 )) || { echo "need at least two themes in $dir/themes" >&2; exit 1; }

current=$(sed -n 's/^theme = //p' "$config" | head -1)

next="${themes[0]}"
for i in "${!themes[@]}"; do
    if [[ "${themes[$i]}" == "$current" ]]; then
        next="${themes[$(( (i + 1) % ${#themes[@]} ))]}"
        break
    fi
done

# In-place edit without a temp file so the config's inode (and any watcher) survives.
python3 - "$config" "$next" <<'PY'
import re, sys
path, theme = sys.argv[1], sys.argv[2]
s = open(path).read()
s, n = re.subn(r'(?m)^theme = .*$', 'theme = ' + theme, s, count=1)
if not n:
    raise SystemExit('no "theme = " line found in ' + path)
open(path, 'w').write(s)
PY

pkill -USR2 -f 'Ghostty.app/Contents/MacOS/ghostty' 2>/dev/null || true
echo "theme -> $next"
