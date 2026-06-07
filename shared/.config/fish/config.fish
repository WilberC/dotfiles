# Fish shell configuration
# Most config lives in conf.d/ for modularity and stow compatibility

# Fish v4: Enable dotglob (equivalent to zsh GLOB_DOTS)
set -g fish_features globdots

# Disable greeting
set -g fish_greeting

if test (uname) = Darwin
  source ~/.orbstack/shell/init2.fish 2>/dev/null || true
end

fish_add_path -g "$HOME/.local/bin"

function clean-zone-watch
  set -l watch_dir "$PWD"
  if set -q argv[1]
    set watch_dir "$argv[1]"
  end

  mkdir -p "$HOME/.cache"
  nohup watch-zone-identifiers "$watch_dir" > "$HOME/.cache/watch-zone-identifiers.log" 2>&1 &
end
