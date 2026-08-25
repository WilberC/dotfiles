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

# Markdown
alias md glow

# Development
alias dev bin/dev
alias until_failure ~/scripts/until_failure
alias pi 'mise exec node@lts -- pi'
alias codex 'mise exec node@lts -- codex -p dotfiles --dangerously-bypass-approvals-and-sandbox'

# Herdr
alias hf 'herdr --remote forge'
alias hfk 'herdr --remote forge --remote-keybindings server'

# Claude Code
alias cc claude
alias cca 'claude --dangerously-skip-permissions'
alias ccar 'claude --dangerously-skip-permissions --resume'
alias ccr 'claude --resume'
alias ccp 'claude --print'
