# Homelab SSH

How `ssh <alias>` reaches homelab hosts (Proxmox VMs, LXC containers, and
other machines like `forge`) passwordlessly, how the private host list
stays out of a public repo, and how to add/authorize a new host.

## Architecture

- **`shared/.config/ssh/configs/homelab.conf`** — the actual `Host` blocks
  (aliases, IPs, users). Private: gitignored, synced through a 1Password
  Secure Note instead of git (see [SSH config groups](#ssh-config-groups)
  below). `homelab.conf.example` is the committed template.
- **1Password SSH Agent** — holds the actual private key material. Nothing
  private-key-shaped ever touches disk; `.pub` files (public keys) are
  committed normally, since publishing a public key is safe by design.
- **WSL2 agent relay** — WSL's native `ssh` can't reach 1Password's agent
  directly (it's a Windows named pipe). `os/wsl2/.local/bin/1password-ssh-agent-relay`
  bridges it into a Unix socket at `~/.1password/agent.sock` via
  `npiperelay.exe` + `socat`, run by the
  `1password-ssh-agent-relay` systemd user service (enabled automatically
  by `install.sh` on WSL2). `~/.ssh/config`'s `IdentityAgent` points at that
  socket. Only relevant on WSL2 — native Linux/macOS reach the agent
  directly.
- **Keys**: most hosts share one dedicated key, **"Local Lab SSH"** in
  1Password (`~/.config/ssh/pubs/homelab.pub`), since they're all under one
  trust boundary. A host can use its own dedicated key instead (see
  `hermes` in `homelab.conf` — key `"Hermes Agent SSH"`,
  `~/.config/ssh/pubs/hermes.pub`) when it warrants separate blast radius.

## Adding a new host

1. **Find its IP/name.** On the Proxmox host:
   ```bash
   proxmox-list-guests.sh
   ```
   Lists every LXC and VM (ID, name, IP, MAC) in a table. VMs need
   `qemu-guest-agent` installed and running inside the guest for their IP
   to show up.

2. **Add a `Host` block** to `shared/.config/ssh/configs/homelab.conf`
   (copy the format from `homelab.conf.example`):
   ```
   Host <alias>
     HostName <ip>
     User <user>
     IdentityFile ~/.config/ssh/pubs/homelab.pub
     IdentitiesOnly yes
   ```
   Use a different `IdentityFile` only if this host needs its own
   dedicated key instead of the shared one.

3. **Restow** so the new `Host` block takes effect immediately:
   ```bash
   bash ~/dotfiles/scripts/stow-shared.sh
   ```

4. **Authorize the key on the host itself** — see below, the method
   depends on whether the host allows SSH password auth.

5. **Push the updated config to 1Password** so other machines can pull it:
   ```bash
   bash ~/dotfiles/scripts/ssh-config.sh push homelab
   ```

## Authorizing the key on a host

Two different tools, because **LXC container templates default to
`PermitRootLogin prohibit-password`** (OpenSSH's own default when the
directive is left at its commented-out default) — this blocks SSH
password auth for `root` entirely, so anything that bootstraps over SSH
can't reach them.

- **`scripts/ssh-copy-homelab-keys.sh`** — for anything reachable via SSH
  password auth (VMs, `forge`, any host without the LXC restriction).
  Connects over SSH once (prompts for that host's password) and appends
  the key to `~/.ssh/authorized_keys`, idempotently.
  ```bash
  bash ~/dotfiles/scripts/ssh-copy-homelab-keys.sh          # fzf picker: Tab to mark, Ctrl-A for all
  bash ~/dotfiles/scripts/ssh-copy-homelab-keys.sh --all    # every selectable host, no picker
  bash ~/dotfiles/scripts/ssh-copy-homelab-keys.sh dokploy  # explicit host(s) by name
  ```
  `SKIP_HOSTS` at the top of the script excludes hosts that can't go
  through this path (LXC containers, or anything already authorized
  manually) from the picker/`--all`, while still letting them be targeted
  explicitly by name.

- **`tools/proxmox-authorize-lxc-keys.sh`** — for LXC containers. Runs
  **on the Proxmox host** and uses `pct exec`, which never touches SSH, so
  the `PermitRootLogin` restriction doesn't apply. Same picker/`--all`/
  explicit-IDs interface:
  ```bash
  proxmox-authorize-lxc-keys.sh          # picker
  proxmox-authorize-lxc-keys.sh --all    # every running container
  proxmox-authorize-lxc-keys.sh 110 111  # explicit IDs
  ```
  Both scripts are purely additive — they never touch `PasswordAuthentication`
  or disable password login; the key is just a new login method alongside it.

### Baking the key into new LXC containers at creation time

`pct create` accepts `--ssh-public-keys <file>` to inject the key
immediately, skipping the authorize step for anything created that way.
The public key is kept on the Proxmox host at `/root/proxmox/keys/homelab.pub`
for this:
```bash
pct create <id> <template> ... --ssh-public-keys /root/proxmox/keys/homelab.pub
```

## SSH config groups

`scripts/ssh-config.sh` is the general sync mechanism `homelab.conf` uses
— any `shared/.config/ssh/configs/<group>.conf.example` file is
auto-discovered as a syncable "group", whose real `<group>.conf` is
gitignored and synced through a 1Password Secure Note
(`dotfiles/<group>-ssh.conf`) instead of git.

```bash
bash ~/dotfiles/scripts/ssh-config.sh              # picker: pick push/pull, then group(s)
bash ~/dotfiles/scripts/ssh-config.sh push homelab
bash ~/dotfiles/scripts/ssh-config.sh pull homelab # on another machine
```

`homelab` is currently the only group; adding another just means dropping
in a new `<name>.conf.example` — no code changes needed.

## Discovering guests

`tools/proxmox-list-guests.sh` runs on the Proxmox host and tables every
LXC/VM with ID, name, IP, and MAC, color-coded by state (green = running
with IP resolved, yellow = running but no IP resolved, dim = stopped). For
VMs it filters the guest agent's reported interfaces down to the one
matching the VM's actual NIC MAC (`net0`/`net1`/...) — necessary because a
VM running Docker reports dozens of bridge/veth IPs otherwise. Copy it to
the Proxmox host to use:
```bash
scp ~/dotfiles/tools/proxmox-list-guests.sh root@<proxmox-host>:/usr/local/bin/
ssh root@<proxmox-host> proxmox-list-guests.sh
```

## Troubleshooting

- **`ssh <alias>` says "Could not resolve hostname... No such host is
  known"** — that's Windows' `ssh.exe` error phrasing, not WSL's. You're
  likely in a stale terminal tab, or one where `ssh` somehow resolves to
  the Windows binary instead of `/usr/bin/ssh`. Check with `which -a ssh`
  and open a fresh WSL terminal.
- **"UNPROTECTED PRIVATE KEY FILE" warning on a `.pub` file, then
  `Permission denied`** — OpenSSH refuses a `.pub` `IdentityFile` hint if
  its permissions are too open, even though it's public key material.
  `chmod 600` the file. `install.sh` reasserts this on every run for
  `~/.config/ssh/pubs/*.pub` since git doesn't track full permission bits.
- **A VM shows `(sin agent/IP)` in `proxmox-list-guests.sh`** — either
  `qemu-guest-agent` isn't installed/running inside the guest
  (`sudo apt install -y qemu-guest-agent && sudo systemctl enable --now qemu-guest-agent`),
  or the response is taking longer than the script's timeout (a Docker
  host with many interfaces can be slow to enumerate).
