# WSL2 SSH & Git Identity Bugs

## Status: pending (currently on macOS)

---

## Bug 1 — SSH tries all keys instead of the correct one

### Root cause

`wsl2/.config/zsh/config.d/30-dependencies.zsh` aliases `ssh` → `ssh.exe` and `ssh-add` → `ssh-add.exe` (Windows binaries). `ssh.exe` reads the **Windows** SSH config (`C:\Users\wilber\.ssh\config`), not the Linux one at `~/.ssh/config`. The shared `.conf` files stowed to `~/.config/ssh/configs/` are never seen by `ssh.exe`, so it offers all keys and tries them one by one.

### Fix: switch to native Linux SSH + npiperelay bridge

Use native Linux SSH connecting to the Windows 1Password agent via a Unix socket bridge. This keeps all host config in one place (the shared `.conf` files) rather than replicating them into the Windows SSH config.

**Prerequisites:**
- Windows: `npiperelay.exe` → `scoop install npiperelay`
- WSL2: `socat` → `sudo apt install socat`

**1. `wsl2/.config/zsh/config.d/30-dependencies.zsh`**

Remove:
```zsh
alias ssh='ssh.exe'
alias ssh-add='ssh-add.exe'
```

Add:
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

`IdentityAgent ~/.1password/agent.sock` — path stays the same, now points to the bridge socket.

---

## Bug 2 — Git commits always use personal identity in WSL2, never work identity

### Root cause

Not fully investigated. Likely cause: `git` resolves to `git.exe` from Windows PATH, which reads the Windows gitconfig rather than the Linux one — ignoring all `includeIf` blocks in `~/.config/gitconfig/`.

### Fix

Investigate after Bug 1 is resolved:
1. Check which `git` binary is active in WSL2: `which git`
2. If it's `git.exe`, ensure Linux git takes precedence in PATH
3. Trace the gitconfig include chain: `git config --list --show-origin`
