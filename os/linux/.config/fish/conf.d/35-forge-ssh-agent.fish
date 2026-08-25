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
    set -l local_agent $agent_dir/openssh_agent
    set -l data_home ~/.local/share
    if set -q XDG_DATA_HOME; and test -n "$XDG_DATA_HOME"
        set data_home $XDG_DATA_HOME
    end

    # A Forge-local agent is the zero-friction headless-server path. The
    # marker is created by the first `forge-keys import`; other Linux hosts and Forge
    # before setup retain the forwarded-agent behavior below.
    if test -e $data_home/forge-keys/enabled; and test -S $local_agent
        set -gx SSH_AUTH_SOCK $local_agent
        return
    end

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
