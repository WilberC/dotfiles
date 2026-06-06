# Plugin/tool activation

if not command -q mise
    curl https://mise.jdx.dev/install.sh | sh
end

if status is-interactive
    mise activate fish | source
else
    mise activate fish --shims | source
end

if not type -q fisher
  curl -sL https://git.io/fisher | source
end

if command -q starship
    starship init fish | source
end

if command -q atuin
    atuin init fish | source
end

if command -q zoxide
    zoxide init fish | source
end

if command -q fzf
    fzf --fish | source
end
