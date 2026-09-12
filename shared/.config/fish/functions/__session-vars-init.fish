function __session-vars-init
    if set -q CODEX_SESSION_VARS_DIR
        return 0
    end

    set -l runtime_dir "$TMPDIR"
    if not test -n "$runtime_dir"
        set runtime_dir /tmp
    end

    set -l root "$runtime_dir/codex-session-vars"
    command mkdir -m 700 -p "$root"
    command find "$root" -mindepth 1 -maxdepth 1 -type d -name 'session-*' -mmin +1440 -exec rm -rf -- {} + 2>/dev/null

    set -gx CODEX_SESSION_VARS_DIR (command mktemp -d "$root/session-$fish_pid.XXXXXX")
    command chmod 700 "$CODEX_SESSION_VARS_DIR"
end
