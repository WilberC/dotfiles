# Environment variables

test -d ~/.local/bin; or mkdir -p ~/.local/bin

fish_add_path -aP ~/.local/bin
fish_add_path -aP ~/.cargo/bin
if test -d ~/dotfiles-secrets/bin
    fish_add_path -aP ~/dotfiles-secrets/bin
else
    echo "warn: ~/dotfiles-secrets not found — 'secrets' unavailable" >&2
end

set -gx PAGER less
set -gx CODEX_HOME "$HOME/.codex"

# fzf — use bfs for faster file listing (breadth-first, respects ignores)
set -gx FZF_DEFAULT_COMMAND 'bfs --type f 2>/dev/null'
set -gx FZF_DEFAULT_OPTS '--height 40% --layout reverse --border'
