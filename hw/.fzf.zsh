# Setup fzf
# ---------
if [[ ! "$PATH" == */home/hw/.fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/home/hw/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/home/hw/.fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "/home/hw/.fzf/shell/key-bindings.zsh"
