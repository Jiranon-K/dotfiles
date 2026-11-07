# Windows installer for the Herdr part of these dotfiles.
#   powershell -ExecutionPolicy Bypass -File .\install.ps1
# Installs the Herdr app (official script, verifies the release sha256, no admin),
# copies the catppuccin-mocha theme, the herdr-skillshare layout and its mod into
# ~/.config/herdr-app, and selects the theme. Safe to re-run.
$ErrorActionPreference = "Stop"

$dotfiles = $PSScriptRoot
$herdrHome = if ($env:HERDR_APP_HOME) { $env:HERDR_APP_HOME } else { Join-Path $env:USERPROFILE ".config\herdr-app" }
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$utf8 = New-Object System.Text.UTF8Encoding($false)   # Herdr rejects a BOM in JSON

function Say($m)  { Write-Host "==> $m" -ForegroundColor Magenta }
function Ok($m)   { Write-Host "  + $m" -ForegroundColor Green }
function Warn($m) { Write-Host "  ! $m" -ForegroundColor Yellow }

# Copy, not symlink: symlinks need admin or Developer Mode on Windows.
function Copy-Config($src, $dst, $name) {
    New-Item -ItemType Directory -Force (Split-Path $dst) | Out-Null
    if (Test-Path $dst) {
        $same = (Test-Path $src -PathType Leaf) -and ((Get-FileHash $src).Hash -eq (Get-FileHash $dst).Hash)
        if ($same) { Ok "$name already current"; return }
        Move-Item $dst "$dst.backup-$stamp"
        Warn "previous $name moved to $(Split-Path $dst -Leaf).backup-$stamp"
    }
    Copy-Item $src $dst -Recurse
    Ok "$name -> $dst"
}

Say "Herdr"
$installed = (Get-Command herdr-app -ErrorAction SilentlyContinue) -or
             (Test-Path (Join-Path $env:LOCALAPPDATA "Programs\herdr-app\herdr-app.exe"))
if ($installed) {
    Ok "Herdr already installed"
} else {
    try {
        Invoke-RestMethod https://releases.herdr.dev/app/install.ps1 | Invoke-Expression
        Ok "Herdr installed (open a new terminal for PATH)"
    } catch {
        Warn "Herdr install failed: $($_.Exception.Message) - see https://herdr.dev/download"
    }
}

Say "Herdr config"
Copy-Config "$dotfiles\herdr\themes\catppuccin-mocha.json" "$herdrHome\themes\catppuccin-mocha.json" "theme"
Copy-Config "$dotfiles\herdr\layouts\herdr-skillshare.json" "$herdrHome\layouts\herdr-skillshare.json" "layout"
Copy-Config "$dotfiles\herdr\layouts\herdr-skillshare.png"  "$herdrHome\layouts\herdr-skillshare.png"  "layout preview"
# A mod is a folder: replace it whole (old copy is kept as a backup).
if (Test-Path "$herdrHome\mods\skillshare") {
    Move-Item "$herdrHome\mods\skillshare" "$herdrHome\mods\skillshare.backup-$stamp"
    Warn "previous mod moved to skillshare.backup-$stamp"
}
New-Item -ItemType Directory -Force "$herdrHome\mods" | Out-Null
Copy-Item "$dotfiles\herdr\mods\skillshare" "$herdrHome\mods\skillshare" -Recurse
Ok "skillshare mod -> $herdrHome\mods\skillshare"

# Select the theme without touching the rest of settings.json.
$settingsPath = Join-Path $herdrHome "settings.json"
$settings = if (Test-Path $settingsPath) { Get-Content $settingsPath -Raw | ConvertFrom-Json } else { [pscustomobject]@{} }
$settings | Add-Member -NotePropertyName theme -NotePropertyValue "catppuccin-mocha" -Force
[IO.File]::WriteAllText($settingsPath, ($settings | ConvertTo-Json -Depth 8), $utf8)
Ok "theme: catppuccin-mocha"

Write-Host "`nDone. In Herdr press ctrl+shift+l to switch to the herdr-skillshare layout." -ForegroundColor Green
Write-Host "The skillshare panel runs 'sh', 'git' and the 'skillshare' CLI; on Windows 'sh' comes from Git for Windows." -ForegroundColor DarkGray
