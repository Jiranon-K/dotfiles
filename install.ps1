# Windows installer for the Herdr and Claude Code statusline parts of these dotfiles.
#   powershell -ExecutionPolicy Bypass -File .\install.ps1 [-StartDir D:\Project] [-Skillshare]
# - Installs the Herdr app (official script, verifies the release sha256, no admin).
# - Copies the catppuccin-mocha theme into ~/.config/herdr-app and selects it.
# - Makes new Herdr spaces (ctrl-shift-n) and tabs (ctrl-shift-t) start in -StartDir.
# - Installs jq (winget) and wires claude/statusline.sh into ~/.claude/settings.json.
# The skillshare layout/mod is opt-in (-Skillshare): its panel needs the skillshare CLI,
# which an Application Control policy may block on locked-down machines.
# Safe to re-run.
param(
    [string]$StartDir = "D:\Project",
    [switch]$Skillshare
)
$ErrorActionPreference = "Stop"

$dotfiles = $PSScriptRoot
$herdrHome = if ($env:HERDR_APP_HOME) { $env:HERDR_APP_HOME } else { Join-Path $env:USERPROFILE ".config\herdr-app" }
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$utf8 = New-Object System.Text.UTF8Encoding($false)   # Herdr rejects a BOM in JSON

function Say($m)  { Write-Host "==> $m" -ForegroundColor Magenta }
function Ok($m)   { Write-Host "  + $m" -ForegroundColor Green }
function Warn($m) { Write-Host "  ! $m" -ForegroundColor Yellow }
function Read-Json($p) { if (Test-Path $p) { Get-Content $p -Raw | ConvertFrom-Json } else { [pscustomobject]@{} } }
function Write-Json($p, $o) { [IO.File]::WriteAllText($p, ($o | ConvertTo-Json -Depth 20), $utf8) }
function Set-Prop($o, $name, $value) { $o | Add-Member -NotePropertyName $name -NotePropertyValue $value -Force }

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

# ── Herdr ────────────────────────────────────────────────────
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

if ($Skillshare) {
    Copy-Config "$dotfiles\herdr\layouts\herdr-skillshare.json" "$herdrHome\layouts\herdr-skillshare.json" "layout"
    Copy-Config "$dotfiles\herdr\layouts\herdr-skillshare.png"  "$herdrHome\layouts\herdr-skillshare.png"  "layout preview"
    # A mod is a folder: replace it whole (old copy is kept as a backup).
    if (Test-Path "$herdrHome\mods\skillshare") {
        Move-Item "$herdrHome\mods\skillshare" "$herdrHome\mods\skillshare.backup-$stamp"
        Warn "previous mod moved to skillshare.backup-$stamp"
    }
    New-Item -ItemType Directory -Force "$herdrHome\mods" | Out-Null
    Copy-Item "$dotfiles\herdr\mods\skillshare" "$herdrHome\mods\skillshare" -Recurse
    Ok "skillshare mod -> $herdrHome\mods\skillshare (layout: ctrl+shift+l)"
}

# Select the theme without touching the rest of settings.json.
New-Item -ItemType Directory -Force $herdrHome | Out-Null
$settingsPath = Join-Path $herdrHome "settings.json"
$settings = Read-Json $settingsPath
Set-Prop $settings theme "catppuccin-mocha"
Write-Json $settingsPath $settings
Ok "theme: catppuccin-mocha"

# New spaces/tabs start in $StartDir. Only these two keys are replaced; keys.json is otherwise kept.
$keysPath = Join-Path $herdrHome "keys.json"
if (Test-Path $keysPath) {
    $keys = Read-Json $keysPath
    Set-Prop $keys.global "ctrl-shift-n" ([pscustomobject]@{ command = "space.new"; args = [pscustomobject]@{ folder = $StartDir } })
    Set-Prop $keys.global "ctrl-shift-t" ([pscustomobject]@{ command = "tab.new";   args = [pscustomobject]@{ folder = $StartDir } })
    Write-Json $keysPath $keys
    Ok "ctrl-shift-n / ctrl-shift-t start in $StartDir"
} else {
    Warn "no keys.json yet - start Herdr once, then re-run to set the start folder"
}

# ── Claude Code statusline ───────────────────────────────────
Say "Claude Code statusline"
$jqDir = $null
$jqCmd = Get-Command jq -ErrorAction SilentlyContinue
if (-not $jqCmd -and (Get-Command winget -ErrorAction SilentlyContinue)) {
    winget install --id jqlang.jq -e --accept-package-agreements --accept-source-agreements --silent | Out-Null
}
$jqExe = Get-ChildItem (Join-Path $env:LOCALAPPDATA "Microsoft\WinGet") -Recurse -Filter jq.exe -ErrorAction SilentlyContinue | Select-Object -First 1
if ($jqCmd) { $jqDir = Split-Path $jqCmd.Source } elseif ($jqExe) { $jqDir = $jqExe.DirectoryName }

# Git for Windows' bash is usually not on the PowerShell PATH, but Claude Code runs the command through it.
$hasBash = (Get-Command bash -ErrorAction SilentlyContinue) -or
           ((Get-Command git -ErrorAction SilentlyContinue) -and
            (Test-Path (Join-Path (Split-Path (Split-Path (Get-Command git).Source)) "bin\bash.exe")))
if (-not $hasBash) {
    Warn "bash not found (install Git for Windows) - statusline skipped"
} elseif (-not $jqDir) {
    Warn "jq missing - install it, then re-run (statusline would only show the folder)"
} else {
    # Claude Code started before jq was installed has no jq on PATH, so the command adds its folder.
    # C:\a\b -> /c/a/b (Windows PowerShell 5.1 has no scriptblock -replace, so use .NET)
    function ConvertTo-Msys($p) {
        $p = $p -replace '\\', '/'
        if ($p -match '^([A-Za-z]):(.*)$') { $p = '/' + $Matches[1].ToLower() + $Matches[2] }
        $p
    }
    $script = ConvertTo-Msys "$dotfiles\claude\statusline.sh"
    $cmd = 'PATH="$PATH:' + (ConvertTo-Msys $jqDir) + '" bash "' + $script + '"'
    $csPath = Join-Path $env:USERPROFILE ".claude\settings.json"
    New-Item -ItemType Directory -Force (Split-Path $csPath) | Out-Null
    if (Test-Path $csPath) { Copy-Item $csPath "$csPath.backup-$stamp" }
    $cs = Read-Json $csPath
    Set-Prop $cs statusLine ([pscustomobject]@{ type = "command"; command = $cmd; padding = 0 })
    Write-Json $csPath $cs
    Ok "statusline wired into $csPath (restart claude to see it)"
}

Write-Host "`nDone." -ForegroundColor Green
