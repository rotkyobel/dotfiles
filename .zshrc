# Enable colors and change prompt:
autoload -U colors && colors	# Load colors
PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}$%b "
setopt autocd		# Automatically cd into typed directory.
stty stop undef		# Disable ctrl-s to freeze terminal.
setopt interactive_comments

# History in cache directory:
HISTSIZE=10000000
SAVEHIST=10000000
HISTFILE=~/.cache/zsh/history

# Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)		# Include hidden files.

# vi mode
bindkey -v
export KEYTIMEOUT=1

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

# Change cursor shape for different vi modes.
function zle-keymap-select () {
    case $KEYMAP in
        vicmd) echo -ne '\e[1 q';;      # block
        viins|main) echo -ne '\e[5 q';; # beam
    esac
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

# Use lf to switch directories and bind it to ctrl-o
lfcd () {
    tmp="$(mktemp)"
    lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        rm -f "$tmp" >/dev/null
        [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
    fi
}
bindkey -s '^o' 'lfcd\n'

bindkey -s '^a' 'bc -lq\n'

bindkey -s '^f' 'cd "$(dirname "$(fzf)")"\n'

bindkey '^[[P' delete-char

# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line

# youtube-dl to download stuffs
alias yt='youtube-dl --extract-audio --add-metadata --xattrs --embed-thumbnail --audio-quality 0 --audio-format mp3 -o "%(title)s.%(ext)s"'
alias ytv='youtube-dl --merge-output-format mp4 -f "bestvideo+bestaudio[ext=m4a]/best" --write-srt --sub-lang en --embed-sub -i --embed-thumbnail --add-metadata -o "%(title)s.%(ext)s"'
alias aryt='youtube-dl --merge-output-format mp4 -f "bestvideo+bestaudio[ext=m4a]/best" --write-srt --sub-lang en --embed-sub -i --embed-thumbnail --add-metadata -o "%(title)s.%(ext)s" --external-downloader aria2c --external-downloader-args '-c -j 16 -x 16 -s 16 -k 1M' --file-allocation=falloc'

# St
alias load="kill -USR1 $(pidof st)"
alias use="xrdb merge"

###
alias grep='grep --color=auto'
alias cat='bat --style=plain --paging=never'
alias ls='exa --group-directories-first'
alias l='exa --group-directories-first -l'
alias ll='exa --group-directories-first -l'
alias la='exa --group-directories-first -la'
alias tree='exa -T'

# Personal Scripts
path=('/home/hw/.local/bin' $path)
export PATH

# Fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

wal-fill() {
    wal -n -i "$@"
    feh --bg-fill "$(< "${HOME}/.cache/wal/wal")"
}

# Load syntax highlighting; should be last.
source /usr/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh 2>/dev/null

. /usr/local/bin/z.sh
