# PowerClaude Updater - Windows
# Updates hooks and validate.js to the latest version.
# Does NOT touch: CLAUDE.md, your vault, api-keys.json, settings.json
#
# Run from the cloned repo:
#   .\update.ps1
#
# Or directly from GitHub:
#   irm https://raw.githubusercontent.com/oliverstraus246-beep/powerclaude/main/update.ps1 | iex

$ErrorActionPreference = "Stop"
$claudeDir = "$env:USERPROFILE\.claude"

Write-Host ""
Write-Host "PowerClaude Updater" -ForegroundColor Cyan
Write-Host ""

$scriptDir = $PSScriptRoot
if (-not $scriptDir -or -not (Test-Path (Join-Path ([string]$scriptDir) "free"))) {
    Write-Host "Downloading latest PowerClaude..." -ForegroundColor Yellow
    $tempBase = Join-Path $env:TEMP "powerclaude-update-$(Get-Random)"
    New-Item -ItemType Directory -Path $tempBase -Force | Out-Null
    $zipPath = "$tempBase\repo.zip"
    try {
        Invoke-WebRequest "https://github.com/oliverstraus246-beep/powerclaude/archive/refs/heads/main.zip" -OutFile $zipPath -UseBasicParsing
        Expand-Archive $zipPath -DestinationPath $tempBase -Force
        $scriptDir = "$tempBase\powerclaude-main"
    } catch {
        Write-Host "  Download failed: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

if (-not (Test-Path "$claudeDir\hooks")) {
    Write-Host "  [FAIL] ~/.claude/hooks not found. Run install.ps1 first." -ForegroundColor Red
    exit 1
}

# Update hooks
$hooksSrc = Join-Path $scriptDir "free\hooks"
Get-ChildItem "$hooksSrc\*.js" | ForEach-Object {
    Copy-Item $_.FullName "$claudeDir\hooks\" -Force
    Write-Host "  Updated: hooks\$($_.Name)" -ForegroundColor Green
}

# Update validate.js
$validateSrc = Join-Path $scriptDir "validate.js"
if (Test-Path $validateSrc) {
    Copy-Item $validateSrc "$claudeDir\validate.js" -Force
    Write-Host "  Updated: validate.js" -ForegroundColor Green
}

Write-Host ""
Write-Host "Update complete." -ForegroundColor Green
Write-Host "  CLAUDE.md, vault, api-keys.json, and settings.json were not changed." -ForegroundColor Gray
Write-Host ""
