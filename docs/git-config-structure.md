# Git Config Structure

The git configuration is split across `git/` and `shared/.config/gitconfig/` to keep each file focused and easy to maintain.

## Entry point

`git/.gitconfig` — core settings only (`[core]`, `[init]`) plus includes that load everything else.

## Shared config files

`shared/.config/gitconfig/`

| File | What it controls |
|------|-----------------|
| `accounts/identity` | Default identity + directory-based account switching (personal vs Outcode) |
| `accounts/personal` | Personal git identity |
| `accounts/outcode` | Work git identity |
| `signing` | GPG format (SSH) and commit signing |
| `ui` | Display preferences: column layout, branch sort, diff algorithm, difftastic difftool, help |
| `workflow` | Day-to-day behaviour: fetch, pull, push, rebase, merge, rerere |
| `delta` | `git-delta` pager config (side-by-side, line numbers) |
| `utils/disable_sign` | Utility include to turn off signing when needed |

## Diff tooling

Two diff renderers are configured and coexist:

| Tool | How to invoke | What it does |
|------|--------------|-------------|
| `delta` | `git diff`, `git show`, `git log -p` (automatic) | Syntax-highlighted pager with side-by-side and line numbers |
| `difftastic` | `git difftool` | Structural/AST diff — understands language syntax, not just lines |

In **lazygit**, both are available as pager options (configured in `shared/.config/lazygit/config.yml`).

## OS-specific

`~/.gitconfig-os-specific` is stowed from `osx/`, `linux/`, or `wsl2/` and sets the 1Password SSH agent socket path per platform.
