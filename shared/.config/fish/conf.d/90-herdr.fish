# Auto-launch herdr in Alacritty only (not other terminals), and never
# inside herdr's own panes (which spawn $SHELL and set HERDR_ENV=1).
#
# ALACRITTY_WINDOW_ID is set natively on Linux/macOS. On WSL2, Alacritty runs
# on Windows and spawns `wsl.exe`, which does not forward that var into the
# Linux session, so the Windows-side alacritty.toml instead sets HERDR_AUTO=1
# explicitly on the wsl.exe command line (see
# %APPDATA%\alacritty\alacritty.toml, not tracked in this repo).
if status is-interactive
    and begin
        set -q ALACRITTY_WINDOW_ID
        or set -q HERDR_AUTO
    end
    and not set -q HERDR_ENV
    and command -q herdr
    herdr
end
