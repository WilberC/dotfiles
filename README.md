<h2 align="center">wilber/dotfiles</h2>

## Quick start

**Linux / WSL2** — upgrade system packages first:

```sh
sudo apt-get update && sudo apt-get upgrade -y
```

Then on all platforms:

```sh
git clone https://github.com/WilberC/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash install.sh
```

> Make sure 1Password is open with the SSH agent enabled before running — it's needed to verify SSH connections and clone the private work configs.

## Docs

- [Install guide](docs/install.md) — what the installer does, step by step
- [SSH config](docs/ssh-config.md) — key inventory, 1Password pattern, adding new hosts
- [Git config structure](docs/git-config-structure.md) — identity switching, conditional includes
- [Zsh config](docs/zsh-config.md) — how to modify and extend
- [Tools and commands](docs/tools-and-commands.md) — everything installed via Brewfile
