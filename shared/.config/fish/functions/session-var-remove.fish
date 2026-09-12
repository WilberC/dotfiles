function session-var-remove -d 'Unset and unregister a secret variable'
    if test (count $argv) -ne 1
        echo 'usage: session-var-remove VARIABLE_NAME' >&2
        return 2
    end

    set -l name $argv[1]
    if not string match -rq '^[A-Za-z_][A-Za-z0-9_]*$' -- "$name"
        echo 'session-var-remove: invalid variable name' >&2
        return 2
    end

    set -ge $name
    if set -q CODEX_SESSION_VARS_DIR
        command rm -f -- "$CODEX_SESSION_VARS_DIR/$name"
    end
end
