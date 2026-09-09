# Auto-launch herdr in Alacritty only (not other terminals), and never
# inside herdr's own panes (which spawn $SHELL and set HERDR_ENV=1).
#
# ALACRITTY_WINDOW_ID is set natively on Linux/macOS. On WSL2, Alacritty runs
# on Windows and spawns `wsl.exe`, which does not forward that var into the
# Linux session, so the Windows-side alacritty.toml instead sets HERDR_AUTO=1
# explicitly on the wsl.exe command line (see
# %APPDATA%\alacritty\alacritty.toml, not tracked in this repo).
#
# Disabled: launch herdr manually instead, so each new window starts as a
# plain shell and `herdr`/`herdr --remote <host>`/`ssh <host>` is a deliberate
# choice rather than automatic.
# if status is-interactive
#     and begin
#         set -q ALACRITTY_WINDOW_ID
#         or set -q HERDR_AUTO
#     end
#     and not set -q HERDR_ENV
#     and command -q herdr
#     herdr
# end

# Herdr's agent panes (reached via `--remote`, e.g. `hf`) start with
# NO_COLOR=1 in the process environment. This isn't set anywhere in this
# repo — confirmed by inspecting `env` inside a live Claude Code pane — so
# it's Herdr itself injecting it, likely to keep its own plain-text agent
# state detection reliable. The side effect: every color-aware CLI run from
# that shell (Claude Code, Codex, etc.) sees NO_COLOR and renders with no
# ANSI colors at all. Undo it for interactive herdr panes so agent output
# keeps its colors.
if status is-interactive; and set -q HERDR_ENV
    set -e NO_COLOR
    set -gx FORCE_COLOR 1
end
