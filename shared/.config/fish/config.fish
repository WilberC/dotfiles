# Fish shell configuration
# Most config lives in conf.d/ for modularity and stow compatibility

# Fish v4: Enable dotglob (equivalent to zsh GLOB_DOTS)
set -g fish_features globdots

# Disable greeting
set -g fish_greeting

if test (uname) = Darwin
  source ~/.orbstack/shell/init2.fish 2>/dev/null || true
end
