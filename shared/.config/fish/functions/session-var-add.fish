function session-var-add -d 'Read a secret into this Fish session and register only its name'
    if test (count $argv) -ne 1
        echo 'usage: session-var-add VARIABLE_NAME' >&2
        return 2
    end

    set -l name $argv[1]
    if not string match -rq '^[A-Za-z_][A-Za-z0-9_]*$' -- "$name"
        echo 'session-var-add: invalid variable name' >&2
        return 2
    end

    read --silent --prompt-str "Value for $name: " value
    echo
    or return 1

    __session-vars-init
    set -gx $name $value
    command touch "$CODEX_SESSION_VARS_DIR/$name"
    command chmod 600 "$CODEX_SESSION_VARS_DIR/$name"
    command touch "$CODEX_SESSION_VARS_DIR"
    set -e value
    echo "Registered $name for this Fish session."
end
