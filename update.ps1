# PowerClaude Updater - Windows
# Pulls the latest version and applies non-destructive updates.
# Your CLAUDE.md, vault, and api-keys.json are never touched.
#
# Run: .\update.ps1  (from cloned repo)

$ErrorActionPreference = "Stop"
$claudeDir = "$env:USERPROFILE\.claude"

Write-Host ""
Write-Host "PowerClaude Updater" -ForegroundColor Cyan
Write-Host ""

# Pull latest
Write-Host "Pulling latest from GitHub..." -ForegroundColor Yellow
git pull origin main
Write-Host "  Up to date" -ForegroundColor Green
Write-Host ""

# Update hooks (safe to overwrite - these are not user-edited)
Write-Host "Updating hooks..." -ForegroundColor Yellow
$hooksSrc = Join-Path $PSScriptRoot "free\hooks"
if (Test-Path $hooksSrc) {
    Get-ChildItem "$hooksSrc\*.js" | ForEach-Object {
        Copy-Item $_.FullName "$claudeDir\hooks\" -Force
        Write-Host "  Updated $($_.Name)" -ForegroundColor Green
    }
}

# Update CLAUDE.md template (not CLAUDE.md itself - that is yours)
$tmplSrc = Join-Path $PSScriptRoot "free\CLAUDE.md.template"
if (Test-Path $tmplSrc) {
    Copy-Item $tmplSrc "$claudeDir\CLAUDE.md.template" -Force
    Write-Host "  Updated CLAUDE.md.template" -ForegroundColor Green
}

Write-Host ""
Write-Host "Updated:" -ForegroundColor Green
Write-Host "  Hooks:    $claudeDir\hooks\"
Write-Host "  Template: $claudeDir\CLAUDE.md.template"
Write-Host ""
Write-Host "Not touched (yours to keep):" -ForegroundColor Gray
Write-Host "  $claudeDir\CLAUDE.md"
Write-Host "  $claudeDir\api-keys.json"
Write-Host "  $env:CLAUDE_VAULT_PATH"
Write-Host ""
Write-Host "Run validate.js to confirm everything is still wired correctly:" -ForegroundColor Yellow
Write-Host "  node validate.js"
Write-Host ""
