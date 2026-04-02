# SSH Key Inventory — Is It Needed?

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
