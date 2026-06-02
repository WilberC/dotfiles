# Tech Debt

Nothing here — enjoy the clean slate.

## gtab: resize_split via AppleScript doesn't work

`perform action "resize_split:up/down,N"` on a terminal surface is silently ignored — neither direction nor comma/colon syntax variations had any effect.

**Tried:**
- `perform action "resize_split:up,10" on p3`
- `perform action "resize_split:down,10" on p1`

**Workaround needed:** Use System Events with a Ghostty keybinding shortcut for resize. Requires adding a `keybind = ...` for `resize_split` to the Ghostty config first, then calling it via `key code` in the AppleScript. See `docs/gtab-workspaces.md`.
