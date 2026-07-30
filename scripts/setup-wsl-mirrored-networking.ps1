<#
.SYNOPSIS
Enables Windows localhost access from WSL2 through mirrored networking.

.DESCRIPTION
Updates the current Windows user's .wslconfig without disturbing other WSL2
settings. Restart WSL after this script completes for the change to take effect.
#>

[CmdletBinding()]
param()

$configPath = Join-Path $env:USERPROFILE '.wslconfig'
$content = if (Test-Path -LiteralPath $configPath) {
    Get-Content -LiteralPath $configPath -Raw
} else {
    ''
}

$wsl2Section = '(?ms)^\[wsl2\](.*?)(?=^\[|\z)'

if ($content -match $wsl2Section) {
    $section = $Matches[0]

    if ($section -match '(?m)^\s*networkingMode\s*=') {
        $updatedSection = $section -replace '(?m)^\s*networkingMode\s*=.*$', 'networkingMode=mirrored'
    } else {
        $updatedSection = $section.TrimEnd() + [Environment]::NewLine + 'networkingMode=mirrored' + [Environment]::NewLine
    }

    $updatedContent = $content.Replace($section, $updatedSection)
} else {
    $separator = if ([string]::IsNullOrWhiteSpace($content) -or $content.EndsWith("`n")) { '' } else { [Environment]::NewLine }
    $updatedContent = $content + $separator + '[wsl2]' + [Environment]::NewLine + 'networkingMode=mirrored' + [Environment]::NewLine
}

if ($updatedContent -ceq $content) {
    Write-Host "Already configured: $configPath"
} else {
    Set-Content -LiteralPath $configPath -Value $updatedContent -NoNewline -Encoding utf8
    Write-Host "Enabled WSL mirrored networking in: $configPath"
}

Write-Host 'Restart WSL when convenient to apply it: wsl --shutdown'
