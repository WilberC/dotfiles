function session-var-list -d 'List secret variable names registered in this Fish session'
    if not set -q CODEX_SESSION_VARS_DIR
        return 0
    end

    for marker in "$CODEX_SESSION_VARS_DIR"/*
        test -f "$marker"; or continue
        basename "$marker"
    end
end
