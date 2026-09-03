# Claude Code status line template

This directory contains a versioned reference copy of the Claude Code status
line script. The live script stays at `~/.claude/statusline-command.sh` as a
plain file, not a symlink, so it is free to diverge per machine without
touching this repository.

## Apply manually

This template is intended to be applied by an AI agent or carefully by hand.
Do not add it to `install.sh` and do not create a separate Claude profile.

1. Copy `statusline-command.sh` to
   `~/.claude/statusline-command.sh` as a plain file.
2. Read `~/.claude/settings.json`, or create it if missing.
3. Merge this entry into the top-level JSON object without replacing unrelated
   settings:

   ```json
   "statusLine": {
     "type": "command",
     "command": "bash /home/wilber/.claude/statusline-command.sh"
   }
   ```

4. Replace `/home/wilber` with the actual home directory when different.
5. Validate the shell script and JSON, then confirm the live script matches the
   template.

## Update the template

This is a one-way, manual reference: applying it does not create a live link,
and edits to `~/.claude/statusline-command.sh` are not synced back
automatically. To roll a change into the template, compare and copy by hand:

```bash
diff -u templates/claude/statusline-command.sh ~/.claude/statusline-command.sh
cp ~/.claude/statusline-command.sh templates/claude/statusline-command.sh
```
