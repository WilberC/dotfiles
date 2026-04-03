# SSH Config Analysis & WSL2 Fix Plan

## Your current setup

All three SSH configs point `IdentityFile` to a `.pub` file, not a private key:

```
shared/.config/ssh/configs/02-github.conf   → IdentityFile ~/.config/ssh/pubs/github_m1.pub
shared/.config/ssh/configs/03-azure.conf    → IdentityFile ~/.config/ssh/pubs/azure_outcode.pub
shared/.config/ssh/configs/04-servers.conf  → IdentityFile ~/.config/ssh/pubs/personal_server.pub
```

This is the 1Password SSH agent pattern. When you set `IdentityFile` to a `.pub` file, SSH reads it to identify *which* key to request, then asks the 1Password agent (via `SSH_AUTH_SOCK`) to perform the actual signing. No private key ever touches the filesystem. This means **all three keys already go through 1Password** — you have full 1Password coverage.

## So is the inventory doc needed?

**Short answer: mostly no, but a small reference is still useful.**

What 1Password already gives you:
- Secure storage of private keys
- A UI listing all your SSH keys
- Audit log of key usage

What 1Password does NOT give you when you're looking at this repo:
- Which key name in 1Password maps to which host
- When each key was created / last rotated
- The fingerprint to cross-check against `ssh-keygen -lf`

## Lightweight recommendation

Instead of a full inventory doc, add a comment to each `.conf` file:

```
# 1Password item: "GitHub Personal (M1)"
# Fingerprint: SHA256:xxxx
# Created: 2024-01
```

That gives you traceability without maintaining a separate document. Run `ssh-keygen -lf ~/.config/ssh/pubs/github_m1.pub` to get the fingerprint.

## If you want a full inventory

| Key file             | 1Password item         | Used for              | Created |
|----------------------|------------------------|-----------------------|---------|
| `github_m1.pub`      | GitHub Personal (M1)   | github.com (personal) | —       |
| `azure_outcode.pub`  | Azure Outcode          | ssh.dev.azure.com     | —       |
| `personal_server.pub`| Personal Server        | myserver (192.168.1.38) | —     |

Fill in the blanks from 1Password, then you're done.

---

## Per-platform `.ssh/config` analysis

Each platform has its own `~/.ssh/config` that sets the 1Password agent socket (platform-specific) and then delegates host configs via `Include ~/.config/ssh/configs/*.conf`.

| Platform | IdentityAgent | Extra |
|----------|--------------|-------|
| `osx` | `~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock` | Also includes OrbStack config |
| `linux` | `~/.1password/agent.sock` | — |
| `wsl2` | `~/.1password/agent.sock` | **Wrong — see below** |

The macOS and Linux setups are correct. The `Include` ordering is also correct: `Host *` wildcard comes first, then `Include` — so host-specific settings in the `.conf` files are not overridden by the wildcard.

---

## WSL2 — Current problems & root cause

### Problem 1: SSH tries all keys instead of going directly to the right one

`wsl2/30-dependencies.zsh` aliases `ssh` → `ssh.exe` and `ssh-add` → `ssh-add.exe` (Windows binaries).
`ssh.exe` reads the **Windows** SSH config (`C:\Users\wilber\.ssh\config`), not the Linux one at `~/.ssh/config`.
The shared `.conf` files (stowed to `~/.config/ssh/configs/`) are never seen by `ssh.exe`, so it offers all keys and tries them one by one.

### Problem 2: Git commits always use personal identity, never Outcode identity

The `includeIf "gitdir:~/Projects/Work/Outcode/"` paths in `shared/.config/gitconfig/accounts/identity` are **correct** — projects are always on the Linux filesystem at `~/Projects/`. The path is not the issue.
Root cause is still to be investigated (likely: `git` resolving to `git.exe` from Windows PATH, or the gitconfig chain not being properly included in WSL2).

---

## WSL2 fix plan — Status: pending (currently on macOS)

### Decision: switch WSL2 to Option B — native Linux SSH + npiperelay bridge

Instead of using `ssh.exe`, use native Linux SSH that connects to the Windows 1Password agent via a Unix socket bridge.

**Why not keep `ssh.exe` (Option C)?**
Fixing it while keeping `ssh.exe` would require replicating the Linux `.conf` files into the Windows SSH config — messy and defeats the purpose of the shared config. Option B keeps everything in one place.

### Prerequisites (install before starting)

- **Windows**: `npiperelay.exe` → `scoop install npiperelay`
- **WSL2**: `socat` → `sudo apt install socat`

### Changes required

**1. `wsl2/.config/zsh/config.d/30-dependencies.zsh`**
- Remove `alias ssh='ssh.exe'` and `alias ssh-add='ssh-add.exe'`
- Add bridge script that starts a `socat` process connecting
  `//./pipe/openssh-ssh-agent` (Windows 1Password named pipe) → `~/.1password/agent.sock` (Unix socket)

```zsh
# Bridge Windows 1Password SSH agent into WSL2
export SSH_AUTH_SOCK="$HOME/.1password/agent.sock"
if [[ ! -S "$SSH_AUTH_SOCK" ]]; then
    rm -f "$SSH_AUTH_SOCK"
    (setsid socat UNIX-LISTEN:"$SSH_AUTH_SOCK",fork \
        EXEC:"npiperelay.exe -ei -s //./pipe/openssh-ssh-agent",nofork &) \
        >/dev/null 2>&1
fi
```

**2. `wsl2/.ssh/config`**
`IdentityAgent ~/.1password/agent.sock` — path stays the same, now points to the bridge socket instead of native 1Password for Linux.

**3. After SSH is fixed**
Investigate the git identity issue separately — check if `git` resolves to Linux git or `git.exe`, and trace the gitconfig include chain in WSL2.
