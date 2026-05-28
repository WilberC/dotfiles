# Aliases

# Directory listing
alias ls 'eza --group-directories-first --icons -A'
alias ll 'eza --group-directories-first --icons -Al --git'
alias tree 'eza --tree -a --git-ignore'
alias treed 'tree --only-dirs'
alias tt 'treed -L 2'
alias ttt 'treed -L 3'

# Git
alias lg lazygit

# Development
alias dev bin/dev
alias until_failure ~/scripts/until_failure
alias pi 'mise exec node@lts -- pi'
alias codex 'mise exec node@lts -- codex'

# Claude Code
alias cc claude
alias cca 'claude --dangerously-skip-permissions'
alias ccr 'claude --resume'
alias ccp 'claude --print'
