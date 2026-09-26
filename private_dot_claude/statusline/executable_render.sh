#!/bin/bash
# Two-row Claude Code statusline · Catppuccin Mocha · Nerd Font icons
#   ╭─ ◆ path · Model · 󰓅 effort · +added/−removed
#   ╰─ 󰘬 branch ●dirty ↑ahead · 󰔟 pct bar used/size
#
# Framed only on the left, deliberately. Claude Code captures our stdout, so
# tput/ioctl cannot see the terminal and the width we are handed goes stale on
# resize — any layout that draws to the right edge ends up either truncated to
# "…" or short of the margin. Nothing here depends on the terminal width.
# Every segment is conditional and disappears when its field is absent.
input=$(cat)

esc() { printf '\033[38;2;%sm' "$1"; }
RESET=$'\033[0m'
BLUE=$(esc "137;180;250");  MAUVE=$(esc "203;166;247")
GREEN=$(esc "166;227;161"); PEACH=$(esc "250;179;135")
RED=$(esc "243;139;168");   TEAL=$(esc "148;226;213")
SURFACE=$(esc "88;91;112")
SEP="   ${SURFACE}·${RESET}   "

# Separator is 0x1f, NOT tab: tab is IFS whitespace, so bash collapses runs of
# it and an empty middle field would shift every later field left.
US=$'\037'
IFS="$US" read -r model cwd pct tok size effort added removed < <(
  jq -r --arg s "$US" '[ .model.display_name                    // "Claude",
                         .workspace.current_dir // .cwd         // "",
                         .context_window.used_percentage        // "",
                         .context_window.total_input_tokens     // "",
                         .context_window.context_window_size    // "",
                         .effort.level                          // "",
                         .cost.total_lines_added                // 0,
                         .cost.total_lines_removed              // 0
                       ] | map(tostring) | join($s)' <<<"$input"
)

# "Opus 5 (1M context)" -> "Opus 5"; the window size already shows in the ctx
# segment as 44k/1.0M, so the parenthetical is pure duplication.
model="${model%% (*}"

pct_color() {
  if   (( $1 >= 80 )); then REPLY=$RED
  elif (( $1 >= 50 )); then REPLY=$PEACH
  else                      REPLY=$GREEN; fi
}
pct_int() {
  REPLY=$(printf '%.0f' "$1" 2>/dev/null) || REPLY=0
  (( REPLY < 0 )) && REPLY=0; (( REPLY > 100 )) && REPLY=100
  return 0
}
human_tok() {                                   # 71680 -> 72k, 1200000 -> 1.2M
  local n=${1%%.*}
  if   (( n >= 1000000 )); then REPLY="$(( n / 100000 ))"; REPLY="${REPLY:0:${#REPLY}-1}.${REPLY: -1}M"
  elif (( n >= 1000 ));    then REPLY="$(( n / 1000 ))k"
  else                          REPLY="$n"; fi
}
shorten_path() {                                # ~/a/b/c/d -> ~/a/.../d
  local p=$1 max=30
  if (( ${#p} <= max )); then REPLY=$p; return; fi
  local IFS=/ parts; read -ra parts <<<"$p"
  local n=${#parts[@]}
  if (( n <= 3 )); then REPLY=$p; return; fi
  # parts[0] is "~", or empty for an absolute path (leading slash).
  REPLY="${parts[0]}/${parts[1]}/.../${parts[n-1]}"
  (( ${#REPLY} <= max )) || REPLY="${parts[0]}/.../${parts[n-1]}"
}

# ── Row 1 ──────────────────────────────────────────────────────────
TILDE='~'                       # via a var: "\~" in a replacement emits a backslash
path="${cwd/#$HOME/$TILDE}"; [ -z "$path" ] && path="/"
shorten_path "$path"; path=$REPLY

row1="${TEAL}◆${RESET} ${BLUE}󰉋  ${path}${RESET}${SEP}${MAUVE}${model}${RESET}"
[ -n "$effort" ] && row1+="${SEP}${TEAL}󰓅  ${effort}${RESET}"
added=${added%%.*}; removed=${removed%%.*}
if (( added > 0 || removed > 0 )); then
  row1+="${SEP}${GREEN}+${added}${RESET} ${RED}−${removed}${RESET}"
fi
printf '%s\n' "${SURFACE}╭─${RESET} ${row1}"

# ── Row 2 ──────────────────────────────────────────────────────────
row2=""
branch=""; dirty=0; ahead=0; behind=0
# One porcelain=v2 call covers branch, upstream divergence and worktree state;
# three separate git invocations here were noticeable on every keystroke.
if [ -n "$cwd" ]; then
  while IFS= read -r line; do
    case $line in
      "# branch.head "*) branch=${line#\# branch.head } ;;
      "# branch.ab "*)   read -r a b <<<"${line#\# branch.ab }"
                         ahead=${a#+}; behind=${b#-} ;;
      [12u]\ *)          (( dirty++ )) ;;
      \?\ *)             (( dirty++ )) ;;
    esac
  done < <(git -C "$cwd" --no-optional-locks status --porcelain=v2 --branch 2>/dev/null)
fi

if [ -n "$branch" ]; then
  [ "$branch" = "(detached)" ] && branch="detached"
  row2="${GREEN}󰘬  ${branch}${RESET}"
  (( dirty  > 0 )) && row2+="  ${PEACH}● ${dirty}${RESET}"
  (( ahead  > 0 )) && row2+="  ${BLUE}↑ ${ahead}${RESET}"
  (( behind > 0 )) && row2+="  ${RED}↓ ${behind}${RESET}"
else
  row2="${SURFACE}○ no repo${RESET}"
fi

if [ -n "$pct" ]; then
  pct_int "$pct"; p=$REPLY
  pct_color "$p"; col=$REPLY
  # Round up so a live-but-tiny context still lights one cell; only a true 0
  # leaves the bar empty.
  filled=$(( (p * 6 + 99) / 100 ))
  (( filled > 6 )) && filled=6
  bar="$col"; i=0
  while (( i < filled )); do bar+="▰"; ((i++)); done
  bar+="$SURFACE"
  while (( i < 6 ));      do bar+="▱"; ((i++)); done
  row2+="${SEP}${SURFACE}󰔟${RESET}  ${col}${p}%${RESET} ${bar}${RESET}"
  if [ -n "$tok" ] && [ -n "$size" ]; then
    human_tok "$tok";  t=$REPLY
    human_tok "$size"; s=$REPLY
    row2+="  ${SURFACE}${t}/${s}${RESET}"
  fi
fi

printf '%s\n' "${SURFACE}╰─${RESET} ${row2}"
