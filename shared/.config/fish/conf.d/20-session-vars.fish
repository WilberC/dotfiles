# Ephemeral secrets shared with tools started from this Fish session.

function __session_vars_cleanup --on-event fish_exit
    if set -q CODEX_SESSION_VARS_DIR
        command rm -rf -- "$CODEX_SESSION_VARS_DIR"
    end
end
