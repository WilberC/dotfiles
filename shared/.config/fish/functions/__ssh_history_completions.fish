function __ssh_history_completions -d "Disabled: don't suggest raw user@host entries from shell history"
    # Overrides fish's builtin (/usr/share/fish/functions) which surfaces any
    # `ssh user@host` ever typed. We only want completions from ~/.ssh/config
    # aliases (__fish_complete_user_at_hosts), not one-off raw IP logins.
end
