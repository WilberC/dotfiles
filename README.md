<h2 align="center">wilberc/dotfiles</h2>

## Prerequisites

- [GNU Stow](https://www.gnu.org/software/stow/)

## Packages

| Package  | Contents                                          | Platform     |
|----------|---------------------------------------------------|--------------|
| `git`    | `.gitconfig`, global `.gitignore`                 | All          |
| `shared` | Fish, Ghostty, Zed, lazygit, mise, amp, scripts, agents | All     |
| `linux`  | OS-specific git config, SSH, local bin            | Linux        |
| `osx`    | OS-specific git config, SSH, LaunchAgents         | macOS        |
| `wsl2`   | OS-specific git config, 1Password socket, Zsh     | WSL2         |

## Installation

```bash
git clone git@github.com:wilberc/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

Stow the packages you need:

```bash
# All platforms
stow git shared

# Pick one OS package
stow linux   # Linux
stow osx     # macOS
stow wsl2    # WSL2
```

## Updating configs

After editing a config file, restow its package:

```bash
stow -R shared
```
