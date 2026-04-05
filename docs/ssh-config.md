# SSH Config

## How it works

All SSH configs use the **1Password SSH agent pattern**: `IdentityFile` points to a `.pub` file, not a private key. SSH reads it to identify which key to request, then asks the 1Password agent (via `SSH_AUTH_SOCK`) to perform the signing. No private key ever touches the filesystem.

Each platform sets the agent socket path in its `~/.ssh/config`, then delegates all host configs via:

```
Include ~/.config/ssh/configs/*.conf
```

This glob picks up both personal configs (stowed from `shared/`) and work configs (stowed from `dotfiles-work/<company>/`) automatically — no manual wiring needed when adding new hosts.

## Per-platform agent socket

| Platform | `IdentityAgent` path |
|----------|---------------------|
| `osx` | `~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock` |
| `linux` | `~/.1password/agent.sock` |
| `wsl2` | `~/.1password/agent.sock` (bridged via `npiperelay` — see WSL2 note) |

## Key inventory

| Public key file | 1Password item | Host | Config file |
|----------------|----------------|------|-------------|
| `github_m1.pub` | GitHub Personal (M1) | `github.com` | `02-github.conf` |
| `personal_server.pub` | Personal Server | `myserver` (192.168.1.38) | `04-servers.conf` |
| `azure_outcode.pub` | Azure Outcode | `ssh.dev.azure.com` | `outcode-azure.conf` (dotfiles-work) |

To get a key fingerprint:

```sh
ssh-keygen -lf ~/.config/ssh/pubs/github_m1.pub
```

## Adding a new host

**Personal host** — add a `.conf` file to `shared/.config/ssh/configs/`:

```
# Description
# 1Password item: "<item name>"
# Fingerprint: (run: ssh-keygen -lf ~/.config/ssh/pubs/<key>.pub)
Host <alias>
  HostName <hostname>
  User <user>
  IdentityFile ~/.config/ssh/pubs/<key>.pub
  IdentitiesOnly yes
```

**Work host** — use `bash add-company.sh` in `dotfiles-work`, or add the `.conf` file manually to the company's stow package. See the [dotfiles-work README](../dotfiles-work/README.md).
