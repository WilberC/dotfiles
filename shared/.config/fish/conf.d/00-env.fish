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
set -gx GLOW_STYLE "$HOME/.config/glow/clean-dark.json"

# Keep Node development servers compatible with IPv4-only SSH port forwards
# (for example Herdr's remote port forwarding). Node 17+ defaults DNS lookups
# to the resolver's verbatim order, which can make `localhost` resolve to ::1
# before 127.0.0.1.
if not string match -q -- '*--dns-result-order=ipv4first*' "$NODE_OPTIONS"
    if set -q NODE_OPTIONS[1]
        set -gx NODE_OPTIONS (string join ' ' -- $NODE_OPTIONS '--dns-result-order=ipv4first')
    else
        set -gx NODE_OPTIONS '--dns-result-order=ipv4first'
    end
end

# fzf — use bfs for faster file listing (breadth-first, respects ignores)
set -gx FZF_DEFAULT_COMMAND 'bfs --type f 2>/dev/null'
set -gx FZF_DEFAULT_OPTS '--height 40% --layout reverse --border'
