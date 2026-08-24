# Herdr's server and panes outlive SSH connections, while agent-forwarding
# creates a new SSH_AUTH_SOCK path for every connection. On forge, keep a
# stable symlink that fresh SSH logins update and persistent Herdr panes use.
if status is-interactive; and test (hostname -s) = forge
    if set -q XDG_RUNTIME_DIR; and test -n "$XDG_RUNTIME_DIR"
        set agent_dir $XDG_RUNTIME_DIR
    else
        set agent_dir /tmp/user-(id -u)
    end

    set -l stable_agent $agent_dir/forge-forwarded-ssh-agent.sock

    # A real SSH login receives a fresh socket. Never replace the stable link
    # with itself or with a stale socket inherited by a persistent Herdr pane.
    if set -q SSH_CONNECTION
        and set -q SSH_AUTH_SOCK
        and test "$SSH_AUTH_SOCK" != "$stable_agent"
        and test -S "$SSH_AUTH_SOCK"
        mkdir -p -m 700 $agent_dir
        ln -sfn -- $SSH_AUTH_SOCK $stable_agent
    end

    # Reuse the latest valid forwarded agent from Herdr panes and new shells.
    if test -S $stable_agent
        set -gx SSH_AUTH_SOCK $stable_agent
    end
end
