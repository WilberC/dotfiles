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

> **Prerequisites:** The terminal must use a [Nerd Font](https://www.nerdfonts.com/font-downloads) for the prompt icons to render correctly (recommended: **MesloLGS NF**, which the p10k wizard installs automatically on first run).

> **Important:** 1Password must be installed and configured before running the installer:
> 1. Enable the **SSH agent** in 1Password Settings → Developer
> 2. Enable **CLI integration** in 1Password Settings → Developer
> 3. Make sure 1Password is **unlocked** before running
>
> This is required for SSH authentication (GitHub) and to clone the private work configs.

## Running individual steps

`install.sh` is a thin orchestrator. Each step can be run standalone:

```sh
bash 01-packages.sh     # prereqs, stow, apt/brew packages, aqua CLI tools
bash 02-verify-ssh.sh   # git identity + GitHub SSH test
bash 03-work.sh         # clone dotfiles-work + post-install hints
```

Useful when you want to re-run only one step — e.g. `bash 02-verify-ssh.sh` to debug SSH without reinstalling packages.

## Fresh WSL2 install

To fully reset Ubuntu and start from scratch, run these from **PowerShell on Windows**:

```powershell
# See installed distros and their names
wsl --list --verbose

# Remove the distro (destructive — deletes all data inside)
wsl --unregister Ubuntu

# Reinstall
wsl --install -d Ubuntu
```

After Ubuntu is back up, follow the Quick start steps above.

## Docs

- [Install guide](docs/install.md) — what the installer does, step by step
- [SSH config](docs/ssh-config.md) — key inventory, 1Password pattern, adding new hosts
- [Git config structure](docs/git-config-structure.md) — identity switching, conditional includes
- [Zsh config](docs/zsh-config.md) — how to modify and extend
- [Package inventory](docs/packages.md) — all packages, per-platform availability at a glance
- [Tools and commands](docs/tools-and-commands.md) — usage reference for installed tools

## Note

This repo is for **personal use**. You're welcome to use the structure as a reference or copy patterns from it, but it is not intended to be used directly by others — it has many personal and private integrations with separate private repos (e.g. `dotfiles-work`, `dotfiles-secrets`) that won't be accessible.

## Possible Improvements

- **[Agent symlink isolation](docs/agent-symlinks.md)** — Currently all agents (`caveman`, `qwen`, `claude`) share the same `.agents/skills` symlink, so changes to one affect all. This is problematic because `caveman` has a special Claude installation (via plugin) and separate configs for Qwen/Kilocode. See the proposed solution using union mounts or wrapper scripts to isolate agent-specific skill directories.

## License

This project is licensed under the [MIT License](LICENSE) — you are free to use, copy, modify, and distribute the structure and patterns found here.
