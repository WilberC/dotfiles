function git-exclude --description 'Add pattern to .git/info/exclude (local-only, never committed)'
    if test (count $argv) -eq 0
        echo "Usage: git-exclude <pattern>"
        return 1
    end
    set -l git_dir (git rev-parse --git-dir 2>/dev/null)
    if test -z "$git_dir"
        echo "Not inside a git repository"
        return 1
    end
    set -l exclude_file "$git_dir/info/exclude"
    mkdir -p (dirname $exclude_file)
    echo $argv[1] >> $exclude_file
    echo "Added '$argv[1]' to $exclude_file"
end
