#!/bin/zsh

##
# Environment variables
#

[ ! -d ~/.local/bin ] && mkdir -p ~/.local/bin

path=(
  $path
  ~/.local/bin
)

# fzf — use bfs for file listing (faster, breadth-first)
export FZF_DEFAULT_COMMAND='bfs --type f 2>/dev/null'
export FZF_DEFAULT_OPTS='--height 40% --layout reverse --border'
