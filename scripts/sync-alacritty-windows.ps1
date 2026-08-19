<#
.SYNOPSIS
Copies the shared Alacritty config into Windows AppData.

.DESCRIPTION
Alacritty on Windows imports this local copy instead of reading
shared/.config/alacritty/alacritty.toml over the WSL2 network filesystem on
every launch, which was adding startup latency. Re-run this after editing
the shared config so Windows picks up the change.
#>

param(
    [Parameter(Mandatory)]
    [string]$Source
)

$destDir = Join-Path $env:APPDATA 'alacritty'
New-Item -ItemType Directory -Path $destDir -Force | Out-Null

$dest = Join-Path $destDir 'shared.toml'
Copy-Item -LiteralPath $Source -Destination $dest -Force
Write-Host "Synced Alacritty config -> $dest"
