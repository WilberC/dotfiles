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
stow -d os -t ~ linux   # Linux
stow -d os -t ~ osx     # macOS
stow -d os -t ~ wsl2    # WSL2
```

> **Stow flags:** `-d <dir>` sets the package directory (where stow looks for packages). `-t <target>` sets where symlinks are created. OS packages need `-t ~` explicitly because `-d os` shifts stow's default target away from `~`.

## Updating configs

After editing a config file, restow its package:

```bash
stow -R shared
```
