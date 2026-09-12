function session-var-clear -d 'Unset all registered secret variables and remove their registry'
    if not set -q CODEX_SESSION_VARS_DIR
        return 0
    end

    for name in (session-var-list)
        set -ge $name
    end
    command rm -rf -- "$CODEX_SESSION_VARS_DIR"
    set -ge CODEX_SESSION_VARS_DIR
end
