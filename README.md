<h2 align="center">wilber/dotfiles</h2>

## Prerequisites

1. [GNU/Stow](https://www.gnu.org/software/stow/)

## Installation

1. Clone onto your machine:

```bash
git clone git@github.com:wilber/dotfiles.git ~/dotfiles
```

2. Install the configuration files you need/want:

```bash
cd ~/dotfiles
stow zsh
stow git
stow osx
```

3. Edit/Replace/Create new config files and restow them:

```bash
stow -R zsh # the folder that contains the new config file
```

## Docs

- [Zsh config — how to modify and extend](docs/zsh-config.md)
- [Git config structure](docs/git-config-structure.md)
- [Tools and commands](docs/tools-and-commands.md)
