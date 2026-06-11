# PowerClaude - Paid Tier Installer (Windows)
# Run this AFTER the free installer: .\install.ps1
#
# What this installs:
#   - Vault-logger hook (auto-logs every session to your vault)
#   - 11 specialized window prompts -> ~/.claude/window-prompts/
#   - Advanced CLAUDE.md template (replaces the basic one)
#   - Personalization engine (generates your CLAUDE.md in 7 questions)

$ErrorActionPreference = "Stop"
$claudeDir = "$env:USERPROFILE\.claude"

Write-Host ""
Write-Host "PowerClaude - Full Version" -ForegroundColor Cyan
Write-Host "Installing paid tier..." -ForegroundColor White
Write-Host ""

# Verify free tier is installed
if (-not (Test-Path "$claudeDir\hooks\session-start.js")) {
    Write-Host "[FAIL] Free tier not found." -ForegroundColor Red
    Write-Host "       Run .\install.ps1 first, then re-run this." -ForegroundColor Yellow
    exit 1
}

$scriptDir = $PSScriptRoot
if (-not $scriptDir) { $scriptDir = Split-Path $MyInvocation.MyCommand.Path -Parent }
if (-not $scriptDir) { $scriptDir = Get-Location }

# 1. Install vault-logger hook
$vaultLoggerSrc = Join-Path $scriptDir "paid\hooks-full\vault-logging\vault-logger.js"
if (Test-Path $vaultLoggerSrc) {
    Copy-Item $vaultLoggerSrc "$claudeDir\hooks\" -Force
    Write-Host "  [ OK ] Vault-logger installed to ~/.claude/hooks/" -ForegroundColor Green
} else {
    Write-Host "  [WARN] vault-logger.js not found in paid/hooks-full/vault-logging/" -ForegroundColor Yellow
}

# 2. Wire vault-logger as Stop hook in settings.json
$settingsPath = "$claudeDir\settings.json"
if (Test-Path $settingsPath) {
    try {
        $s = Get-Content $settingsPath -Raw | ConvertFrom-Json
        $vaultLoggerCmd = "node `"$($claudeDir -replace '\\', '/')/hooks/vault-logger.js`""
        
        # Check if already wired
        $alreadyWired = $false
        if ($s.hooks -and $s.hooks.Stop) {
            foreach ($entry in $s.hooks.Stop) {
                if ($entry.hooks) {
                    foreach ($h in $entry.hooks) {
                        if ($h.command -like "*vault-logger*") { $alreadyWired = $true }
                    }
                }
            }
        }
        
        if (-not $alreadyWired) {
            # Build the Stop hook entry
            $hookObj = [PSCustomObject]@{ type = "command"; command = "node `"$claudeDir\hooks\vault-logger.js`"" }
            $stopEntry = [PSCustomObject]@{ hooks = @($hookObj) }
            
            if (-not $s.hooks) { $s | Add-Member -NotePropertyName hooks -NotePropertyValue ([PSCustomObject]@{}) }
            if (-not $s.hooks.Stop) { $s.hooks | Add-Member -NotePropertyName Stop -NotePropertyValue @() }
            $s.hooks.Stop = @($s.hooks.Stop) + @($stopEntry)
            
            $s | ConvertTo-Json -Depth 10 | Set-Content $settingsPath -Encoding utf8
            Write-Host "  [ OK ] Vault-logger wired as Stop hook in settings.json" -ForegroundColor Green
        } else {
            Write-Host "  [ OK ] Vault-logger already wired in settings.json" -ForegroundColor Gray
        }
    } catch {
        Write-Host "  [WARN] Could not auto-wire Stop hook: $($_.Exception.Message)" -ForegroundColor Yellow
        Write-Host "         Add manually -- see paid/hooks-full/vault-logging/README.md" -ForegroundColor Gray
    }
} else {
    Write-Host "  [WARN] settings.json not found -- run free installer first" -ForegroundColor Yellow
}

# 3. Copy window prompts
$windowSrc = Join-Path $scriptDir "paid\window-prompts-full"
$windowDst = "$claudeDir\window-prompts"
if (Test-Path $windowSrc) {
    New-Item -ItemType Directory -Path $windowDst -Force | Out-Null
    Copy-Item "$windowSrc\*.md" $windowDst -Force
    $count = (Get-ChildItem $windowDst -Filter "*.md").Count
    Write-Host "  [ OK ] $count window prompts installed to ~/.claude/window-prompts/" -ForegroundColor Green
} else {
    Write-Host "  [WARN] window-prompts-full/ not found" -ForegroundColor Yellow
}

# 4. Install advanced CLAUDE.md template (backs up existing)
$advTemplateSrc = Join-Path $scriptDir "paid\advanced-CLAUDE.md.template"
if (Test-Path $advTemplateSrc) {
    $existingTemplate = "$claudeDir\CLAUDE.md.template"
    if (Test-Path $existingTemplate) {
        Copy-Item $existingTemplate "$existingTemplate.free-backup" -Force
    }
    Copy-Item $advTemplateSrc "$claudeDir\CLAUDE.md.template" -Force
    Write-Host "  [ OK ] Advanced CLAUDE.md template installed" -ForegroundColor Green
    Write-Host "         (free template backed up to CLAUDE.md.template.free-backup)" -ForegroundColor Gray
} else {
    Write-Host "  [WARN] advanced-CLAUDE.md.template not found" -ForegroundColor Yellow
}

# 5. Copy personalization engine
$personSrc = Join-Path $scriptDir "paid\personalization-engine.md"
if (Test-Path $personSrc) {
    Copy-Item $personSrc "$claudeDir\personalization-engine.md" -Force
    Write-Host "  [ OK ] Personalization engine installed to ~/.claude/" -ForegroundColor Green
}

# 6. Copy graphify guide
$graphifySrc = Join-Path $scriptDir "paid\graphify-gitnexus-guide.md"
if (Test-Path $graphifySrc) {
    Copy-Item $graphifySrc "$claudeDir\graphify-gitnexus-guide.md" -Force
    Write-Host "  [ OK ] Graphify + GitNexus guide installed" -ForegroundColor Green
}

# Done
Write-Host ""
Write-Host "---" -ForegroundColor Cyan
Write-Host "Paid tier installed." -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  1. Generate your CLAUDE.md automatically (7 questions, takes 2 min):"
Write-Host "     Open Claude Code -> new session -> paste contents of:"
Write-Host "     $claudeDir\personalization-engine.md"
Write-Host ""
Write-Host "  2. Use your window prompts:"
Write-Host "     They are in $claudeDir\window-prompts\"
Write-Host "     Open Claude Code -> new session -> paste any .md file as your first message"
Write-Host "     Each window is specialized (Debug, Planning, Code Review, UI Design, etc.)"
Write-Host ""
Write-Host "  3. Vault-logger is now active:"
Write-Host "     At session end, your work is automatically logged to your vault"
Write-Host ""
Write-Host "Verify setup: node $claudeDir\validate.js" -ForegroundColor Gray
Write-Host ""
