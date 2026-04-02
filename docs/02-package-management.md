# Package Management Parity — Recommendation

## Current state

- `linux/Aptfile` — exists, lists apt packages for Linux
- macOS — nothing tracked. The tool stack (eza, lazygit, delta, difft, ghostty, zed, etc.) lives only in your Homebrew installation, not in the repo.

## Recommendation: add `osx/Brewfile`

A `Brewfile` is the Homebrew equivalent of an `Aptfile`. Run `brew bundle dump` to generate it from what you currently have installed, then curate it down to what you actually want on every machine.

```bash
# Generate from current install (run this once)
brew bundle dump --file=osx/Brewfile

# Install from Brewfile on a new machine
brew bundle --file=osx/Brewfile
```

### What to include

Keep only tools you'd install intentionally on a fresh machine:

```ruby
# Shells / terminal
brew "zsh"
brew "ghostty"          # cask if installed as app

# Git tooling
brew "git"
brew "lazygit"
brew "git-delta"
brew "difftastic"

# File / shell utilities
brew "stow"
brew "eza"
brew "mise"
brew "fzf"

# Editors
cask "zed"

# Dev tools
brew "libpq"
brew "rustup"
```

### What NOT to include

- Work-specific CLIs (keep those personal or in a private dotfiles layer)
- Things installed as side-effects of other tools

## Where it fits

`osx/Brewfile` gets picked up by `install.sh` automatically (see point 1 plan). No extra wiring needed beyond creating the file.
