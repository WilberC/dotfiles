# Claude Code status line template

This directory contains a versioned reference copy of the Claude Code status
line script. The live script stays at `~/.claude/statusline-command.sh` as a
plain file, not a symlink, so it is free to diverge per machine without
touching this repository.

## Use the template

Copy it manually when setting up a new machine or restoring the status line:

```bash
cp templates/claude/statusline-command.sh ~/.claude/statusline-command.sh
```

Then point Claude Code at it in `~/.claude/settings.json`:

```json
"statusLine": {
  "type": "command",
  "command": "bash /home/wilber/.claude/statusline-command.sh"
}
```

## Update the template

This is a one-way, manual reference — copying it does not create a live link,
and edits to `~/.claude/statusline-command.sh` are not synced back
automatically. To roll a change into the template, diff and copy by hand:

```bash
diff -u templates/claude/statusline-command.sh ~/.claude/statusline-command.sh
cp ~/.claude/statusline-command.sh templates/claude/statusline-command.sh
```
