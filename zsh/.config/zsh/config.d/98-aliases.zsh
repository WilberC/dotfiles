#!/bin/zsh

# This lets you change to any dir without having to type `cd`, that is, by just
# typing its name. Be warned, though: This can misfire if there exists an alias,
# function, builtin or command with the same name.
# In general, I would recommend you use only the following without `cd`:
#   ..  to go one dir up
#   ~   to go to your home dir
#   ~-2 to go to the 2nd mostly recently visited dir
#   /   to go to the root dir
setopt AUTO_CD

# No special treatment for file names with a leading dot
setopt GLOB_DOTS

# Require an extra TAB press to open the completion menu
setopt NO_AUTO_MENU

# These aliases enable us to paste example code into the terminal without the
# shell complaining about the pasted prompt symbol.
alias %= \$=

# Set $PAGER if it hasn't been set yet. We need it below.
# `:` is a builtin command that does nothing. We use it here to stop Zsh from
# evaluating the value of our $expansion as a command.
: ${PAGER:=less}

# Associate file name .extensions with programs to open them.
# This lets you open a file just by typing its name and pressing enter.
# Note that the dot is implicit; `gz` below stands for files ending in .gz
alias -s {css,gradle,html,js,json,md,patch,properties,txt,xml,yml}=$PAGER
alias -s gz='gzip -l'
alias -s {log,out}='tail -F'

# Use `< file` to quickly view the contents of any text file.
READNULLCMD=$PAGER

alias secrets='~/dotfiles/dotfiles-secrets/bin/secrets'

alias lg='lazygit'
alias dev='bin/dev'
alias until_failure='~/scripts/until_failure'

# Claude Code
alias cc='claude'
alias cca='claude --dangerously-skip-permissions'  # all permissions, no prompts
alias ccr='claude --resume'                         # resume last conversation
alias ccp='claude --print'                          # non-interactive, print response and exit

alias ls='eza --group-directories-first --icons -A'
alias ll='eza --group-directories-first --icons -Al --git'
alias tree='eza --tree -a --git-ignore'
