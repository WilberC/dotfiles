function alacritty-sync --description 'Sync shared Alacritty config to Windows AppData'
    powershell.exe -ExecutionPolicy Bypass \
        -File (wslpath -w ~/dotfiles/scripts/sync-alacritty-windows.ps1) \
        -Source (wslpath -w ~/dotfiles/shared/.config/alacritty/alacritty.toml)
end
