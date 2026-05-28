# Environment variables

test -d ~/.local/bin; or mkdir -p ~/.local/bin

fish_add_path -aP ~/.local/bin
fish_add_path -aP ~/.cargo/bin

set -gx PAGER less

# fzf — use bfs for faster file listing (breadth-first, respects ignores)
set -gx FZF_DEFAULT_COMMAND 'bfs --type f 2>/dev/null'
set -gx FZF_DEFAULT_OPTS '--height 40% --layout reverse --border'
