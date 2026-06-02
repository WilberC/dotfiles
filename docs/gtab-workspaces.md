# gtab Workspaces

`gtab` saves and restores Ghostty tab layouts via AppleScript. The `gtab save` command captures the entire window including all open tabs and always opens a new window on restore — not ideal for focused workspaces.

## Preferred approach

Manually write the AppleScript so it:
- Opens as a **new tab in the current window** (not a new window)
- Only includes the **panes you want**

> Never run `gtab save <name>` on a manually crafted workspace — it will overwrite it.

## Template

File location: `~/.config/gtab/<name>.applescript`

```applescript
tell application "Ghostty"
    activate

    set win to front window

    set cfg1 to new surface configuration
    set initial working directory of cfg1 to "/absolute/path/to/pane1"
    set newtab to new tab in win with configuration cfg1
    set p1 to focused terminal of newtab
    perform action "set_tab_title:TabName" on p1

    -- Split right
    set cfg2 to new surface configuration
    set initial working directory of cfg2 to "/absolute/path/to/pane2"
    set p2 to split p1 direction right with configuration cfg2

    -- Split down from p1 (bottom-left)
    set cfg3 to new surface configuration
    set initial working directory of cfg3 to "/absolute/path/to/pane3"
    set p3 to split p1 direction down with configuration cfg3

    -- Optional: resize panes (amount is in cells)
    -- perform action "resize_split:up,10" on p3

    -- Optional: navigate focus to a specific pane
    -- perform action "goto_split:up" on p3
end tell

-- Optional: run a command in a specific pane after all splits are ready
-- Use System Events instead of Ghostty's write action (see note below)
delay 1
tell application "Ghostty" to activate
tell application "System Events"
    tell process "Ghostty"
        keystroke "source venv/bin/activate.fish"
        key code 36
    end tell
end tell
```

## Running commands on open

**Problem:** Ghostty's `perform action "write:..."` and `write_scrollback_and_input` do not reliably send input to a terminal surface via AppleScript — the command either doesn't run or is silently ignored.

**Fix:** Use `System Events` to send keystrokes instead, after all panes are created:

```applescript
end tell  -- close the Ghostty block first

delay 1   -- wait for shells to initialize

tell application "Ghostty" to activate
tell application "System Events"
    tell process "Ghostty"
        keystroke "your command here"
        key code 36  -- Return
    end tell
end tell
```

> `key code 36` is the Return key. The `delay 1` is required — without it the keystroke fires before the shell is ready.

**Focus matters:** `System Events` types into whichever pane is currently focused. After creating splits, focus lands on the last pane created. Use `perform action "goto_split:up/down/left/right" on pN` inside the Ghostty block to move focus to the right pane before the keystroke fires.

## Split directions

- `split p1 direction right` — splits p1 vertically, new pane on the right
- `split p1 direction down` — splits p1 horizontally, new pane below
- `split p2 direction down` — splits p2, useful for more complex layouts

## Usage

```
gtab <name>      # open the workspace
gtab list        # list saved workspaces
gtab edit <name> # edit the AppleScript in $EDITOR
```

## Keeping workspaces in dotfiles

Store scripts in `dotfiles/shared/.config/gtab/` so they are symlinked to `~/.config/gtab/` and tracked in git.
