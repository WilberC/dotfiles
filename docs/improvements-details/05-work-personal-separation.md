# Work/Personal Separation — What's Being Proposed

> **Decision (2026-04-02):** Go with **Option B**. This repo stays public as personal dotfiles. Work config moves to a private `dotfiles-work` repo.
> **Status (2026-04-04):** Separation complete. Work files moved to `dotfiles-work/` (gitignored here, lives at `git@github.com:WilberC/dotfiles-work.git`). Bootstrap plan updated to auto-clone it.
> See also: `03-ssh-key-inventory.md` — the SSH key audit will need to be revisited when splitting out the work SSH config.

## Current state (as of 2026-04-04) — DONE

The separation has been completed. Work files now live in `dotfiles-work/` (gitignored in this repo):

```
dotfiles-work/shared/.config/gitconfig/accounts/outcode         ← Outcode git identity (email, signing key)
dotfiles-work/shared/.config/gitconfig/accounts/outcode-include ← Outcode includeIf stanza
dotfiles-work/shared/.config/ssh/configs/03-azure.conf          ← Azure DevOps SSH host config
dotfiles-work/shared/.config/ssh/pubs/azure_outcode.pub         ← Outcode SSH public key
```

`accounts/identity` in this repo now contains only personal identity + personal `includeIf` blocks.

The `dotfiles-work/` directory is the source of truth that will be pushed to `git@github.com:WilberC/dotfiles-work.git`.

### Note on history exposure

Both personal (`wilber.carrascal@gmail.com`) and work (`Wilber.Carrascal@outcodesoftware.com`) emails are already in public git history. The separation going forward is hygiene, not a fix for a past leak.

---

## Original proposal (for reference)

## What's currently in this repo that's work-related

```
shared/.config/gitconfig/accounts/outcode       ← Outcode git identity (name, email, signing key)
shared/.config/gitconfig/main_config            ← conditional include that activates Outcode identity
shared/.config/ssh/configs/03-azure.conf        ← Azure DevOps SSH host config
shared/.config/ssh/pubs/azure_outcode.pub       ← Outcode SSH public key
```

## The concern

If this repo is public (or becomes public), it exposes:
- Your Outcode work email address
- That you work at Outcode
- The Azure DevOps org you connect to
- Your work SSH public key (low risk on its own, but unnecessary to share)

None of this is a credentials leak — there are no private keys or secrets here. But it's information your employer might prefer not to be public, and it ties your personal GitHub identity to your work identity.

## What's being proposed: two options

### Option A: Make the repo private

Simplest fix. Keep everything as-is, just flip the GitHub repo to private. No restructuring needed.

### Option B: Split into two repos

- `dotfiles` (public) — personal configs only: zsh, git personal identity, GitHub SSH, ghostty, zed, lazygit, scripts
- `dotfiles-work` (private) — work overlay: Outcode git identity, Azure SSH config, any work-specific tooling

On a new machine you'd stow both. The work repo can include a small `install.sh` that layers on top of the personal one.

### Option C: Use a private overlay directory (single repo, two remotes)

Keep one repo but add a `private/` directory that's gitignored from the public remote. Use a second git remote (a private repo) that tracks `private/`. Stow picks it up alongside the public configs. More complex to manage.

## Recommendation

**Option A** if you're comfortable with the repo being private and don't plan to share configs publicly.

**Option B** if you want a public personal dotfiles repo (common for developers to share their setup). It's more upfront work but cleaner long-term.

Option C is rarely worth the complexity.
