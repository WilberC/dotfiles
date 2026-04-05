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

> **Important:** 1Password must be installed and configured before running the installer:
> 1. Enable the **SSH agent** in 1Password Settings → Developer
> 2. Enable **CLI integration** in 1Password Settings → Developer
> 3. Make sure 1Password is **unlocked** before running
>
> This is required for SSH authentication (GitHub) and to clone the private work configs.

## Docs

- [Install guide](docs/install.md) — what the installer does, step by step
- [SSH config](docs/ssh-config.md) — key inventory, 1Password pattern, adding new hosts
- [Git config structure](docs/git-config-structure.md) — identity switching, conditional includes
- [Zsh config](docs/zsh-config.md) — how to modify and extend
- [Package inventory](docs/packages.md) — all packages, per-platform availability at a glance
- [Tools and commands](docs/tools-and-commands.md) — usage reference for installed tools
