function sftp-here --description 'Open the current SSH directory with a local SFTP client' --argument-names remote_path
    if test -z "$remote_path"
        set remote_path (pwd)
    else if not string match -q '/*' -- "$remote_path"
        set remote_path (path resolve "$remote_path")
    end

    set -l host
    set -l port

    if set -q SFTP_HOST; and test -n "$SFTP_HOST"
        set host $SFTP_HOST
    else if set -q SSH_CONNECTION
        set -l connection (string split ' ' -- $SSH_CONNECTION)
        set host $connection[3]
    else
        printf 'sftp-here: set SFTP_HOST when running outside an SSH session\n' >&2
        return 1
    end

    if set -q SFTP_PORT; and test -n "$SFTP_PORT"
        set port $SFTP_PORT
    else if set -q SSH_CONNECTION
        set -l connection (string split ' ' -- $SSH_CONNECTION)
        set port $connection[4]
    else
        set port 22
    end

    set -l user $USER
    if set -q SFTP_USER; and test -n "$SFTP_USER"
        set user $SFTP_USER
    end

    # URI hosts containing ':' must be wrapped in brackets (IPv6).
    if string match -q '*:*' -- $host; and not string match -q '[*]' -- $host
        set host "[$host]"
    end

    set -l encoded_user (string escape --style=url -- $user)
    set -l encoded_path (string split / -- $remote_path | string escape --style=url | string join /)
    set -l url "sftp://$encoded_user@$host:$port$encoded_path/"

    # Copy through OSC 52 so the URL reaches the clipboard of the computer
    # running the terminal, including SSH sessions inside tmux.
    printf '%s' $url | fish_clipboard_copy

    # OSC 8 makes the label clickable in terminals such as Ghostty,
    # Windows Terminal and iTerm2. The local OS handles the sftp:// URL.
    printf '\e]8;;%s\e\\Open %s with SFTP\e]8;;\e\\' $url $remote_path
    printf '\nSFTP URL copied to the local clipboard.\n'
end
