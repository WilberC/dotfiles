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
alias codex 'mise exec node@lts -- codex --dangerously-bypass-approvals-and-sandbox'
alias sfh sftp-here

# Herdr
alias h herdr
alias hf 'herdr --remote forge'

# Herdr's remote client leaves its SSH ControlMaster behind if the terminal is
# closed abruptly. Reclaim only masters whose owning Herdr client PID no
# longer exists, so an active remote session is left alone.
function __hfk_cleanup_orphaned_muxes
    for control in /tmp/herdr-ssh-*/ctl
        test -S $control; or continue

        set -l mux_dir (dirname $control)
        set -l mux_name (basename $mux_dir)
        set -l client_pid (string match -r '^herdr-ssh-([0-9]+)-[0-9]+$' $mux_name)[2]
        test -n "$client_pid"; or continue
        kill -0 $client_pid 2>/dev/null; and continue

        set -l ssh_config $mux_dir/config
        ssh -F $ssh_config -S $control -O exit forge >/dev/null 2>&1
    end
end

function hfk
    __hfk_cleanup_orphaned_muxes
    herdr --remote forge --remote-keybindings server $argv
end

# Claude Code
alias cc claude
alias cca 'claude --dangerously-skip-permissions'
alias ccar 'claude --dangerously-skip-permissions --resume'
alias ccr 'claude --resume'
alias ccp 'claude --print'
