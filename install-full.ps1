# PowerClaude Full Installer - Windows (PowerShell)
# Run from the private repo. Installs everything in one pass.
#
#   .\install-full.ps1
#
# What gets installed:
#   - Vault structure + seeded templates
#   - Advanced CLAUDE.md (paid template)
#   - Base hooks + paid hooks (vault-logger, context-bridge, session-start-full)
#   - 11 specialized window prompts
#   - Personalization engine (paste into Claude Code to auto-configure everything)
#   - Graphify + GitNexus guide
#   - settings.json with all hooks wired

$ErrorActionPreference = "Stop"
$claudeDir = "$env:USERPROFILE\.claude"
$today = Get-Date -Format "yyyy-MM-dd"

Write-Host ""
Write-Host "PowerClaude Full Setup" -ForegroundColor Cyan
Write-Host "Installing everything in one pass..." -ForegroundColor White
Write-Host ""

$scriptDir = $PSScriptRoot
if (-not $scriptDir) { $scriptDir = Split-Path $MyInvocation.MyCommand.Path -Parent }
if (-not $scriptDir) { $scriptDir = Get-Location }

# Check for Node.js
$nodeVer = node --version 2>$null
if (-not $nodeVer) {
    Write-Host "  [WARN] Node.js not found. Hooks require Node 18+." -ForegroundColor Red
    Write-Host "         Install from https://nodejs.org then re-run." -ForegroundColor Yellow
    Write-Host ""
}

# ── Vault location ─────────────────────────────────────────────────────────────
Write-Host "Where do you want your Claude vault?" -ForegroundColor Yellow
Write-Host "  [1] $env:USERPROFILE\Documents\Claude  (recommended)"
Write-Host "  [2] $env:USERPROFILE\OneDrive\Claude   (auto-synced)"
Write-Host "  [3] $env:USERPROFILE\Claude             (home folder)"
Write-Host "  [4] Enter a custom path"
Write-Host ""
$choice = Read-Host "Choice [1]"
if (-not $choice) { $choice = "1" }

$vaultRoot = switch ($choice) {
    "2" { "$env:USERPROFILE\OneDrive\Claude" }
    "3" { "$env:USERPROFILE\Claude" }
    "4" { (Read-Host "Enter full path").Trim('"') }
    default { "$env:USERPROFILE\Documents\Claude" }
}

Write-Host ""
Write-Host "  Vault: $vaultRoot" -ForegroundColor Cyan
Write-Host ""

# ── Create vault ───────────────────────────────────────────────────────────────
Write-Host "Creating vault..." -ForegroundColor Yellow

$vaultDirs = @(
    $vaultRoot,
    "$vaultRoot\User Profile",
    "$vaultRoot\Projects",
    "$vaultRoot\Projects\Active",
    "$vaultRoot\Session Takeaways",
    "$vaultRoot\Decisions Log",
    "$vaultRoot\Goals and Ideas",
    "$vaultRoot\Claude and AI",
    "$vaultRoot\Knowledge Base",
    "$vaultRoot\Knowledge Base\Web Development",
    "$vaultRoot\Knowledge Base\Design",
    "$vaultRoot\Knowledge Base\Marketing"
)
foreach ($dir in $vaultDirs) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
}

$vaultTemplates = Join-Path $scriptDir "free\vault-templates"
if (Test-Path $vaultTemplates) {
    Get-ChildItem $vaultTemplates -Recurse -File | ForEach-Object {
        $relativePath = $_.FullName.Substring($vaultTemplates.Length + 1)
        $dest = Join-Path $vaultRoot $relativePath
        New-Item -ItemType Directory -Path (Split-Path $dest -Parent) -Force | Out-Null
        $c = Get-Content $_.FullName -Raw
        $c = $c -replace '\[TODAY\]', $today
        $c = $c -replace '\[VAULT_ROOT\]', $vaultRoot
        Set-Content -Path $dest -Value $c -Encoding utf8
    }
    Write-Host "  [ OK ] Vault seeded" -ForegroundColor Green
} else {
    Set-Content "$vaultRoot\Home.md" "# Home" -Encoding utf8
    Write-Host "  [ OK ] Minimal vault created" -ForegroundColor Yellow
}

# ── ~/.claude setup ────────────────────────────────────────────────────────────
Write-Host "Setting up ~/.claude..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path $claudeDir -Force | Out-Null

$claudeMdPath = "$claudeDir\CLAUDE.md"
if (Test-Path $claudeMdPath) {
    Copy-Item $claudeMdPath "$claudeMdPath.backup" -Force
    Write-Host "  [ OK ] Existing CLAUDE.md backed up" -ForegroundColor Gray
}

# Install advanced (paid) template -- falls back to free if not present
$advTemplateSrc = Join-Path $scriptDir "paid\advanced-CLAUDE.md.template"
$freeTemplateSrc = Join-Path $scriptDir "free\CLAUDE.md.template"
if (Test-Path $advTemplateSrc) {
    Copy-Item $advTemplateSrc "$claudeDir\CLAUDE.md.template" -Force
    Copy-Item $advTemplateSrc $claudeMdPath -Force
    Write-Host "  [ OK ] Advanced CLAUDE.md installed" -ForegroundColor Green
} elseif (Test-Path $freeTemplateSrc) {
    Copy-Item $freeTemplateSrc "$claudeDir\CLAUDE.md.template" -Force
    Copy-Item $freeTemplateSrc $claudeMdPath -Force
    Write-Host "  [ OK ] CLAUDE.md template installed" -ForegroundColor Green
}

$apiKeysPath = "$claudeDir\api-keys.json"
if (-not (Test-Path $apiKeysPath)) {
    $apiKeysSrc = Join-Path $scriptDir "free\api-keys.json.example"
    if (Test-Path $apiKeysSrc) {
        Copy-Item $apiKeysSrc $apiKeysPath -Force
        Write-Host "  [ OK ] api-keys.json created at ~/.claude/" -ForegroundColor Green
    }
}

# ── Hooks ─────────────────────────────────────────────────────────────────────
Write-Host "Installing hooks..." -ForegroundColor Yellow
$hooksDst = "$claudeDir\hooks"
New-Item -ItemType Directory -Path $hooksDst -Force | Out-Null

$hooksSrc = Join-Path $scriptDir "free\hooks"
if (Test-Path $hooksSrc) {
    Get-ChildItem "$hooksSrc\*.js" | ForEach-Object { Copy-Item $_.FullName $hooksDst -Force }
    Write-Host "  [ OK ] Base hooks installed" -ForegroundColor Green
}

$validateSrc = Join-Path $scriptDir "validate.js"
if (Test-Path $validateSrc) {
    Copy-Item $validateSrc "$claudeDir\validate.js" -Force
    Write-Host "  [ OK ] validate.js installed" -ForegroundColor Green
}

$vaultLoggerSrc = Join-Path $scriptDir "paid\hooks-full\vault-logging\vault-logger.js"
if (Test-Path $vaultLoggerSrc) {
    Copy-Item $vaultLoggerSrc $hooksDst -Force
    Write-Host "  [ OK ] Vault-logger installed" -ForegroundColor Green
}

$ctxBridgeSrc = Join-Path $scriptDir "paid\hooks-full\context-bridge\context-bridge.js"
if (Test-Path $ctxBridgeSrc) {
    Copy-Item $ctxBridgeSrc $hooksDst -Force
    Write-Host "  [ OK ] Context-bridge installed" -ForegroundColor Green
}

$sessionFullSrc = Join-Path $scriptDir "paid\hooks-full\context-bridge\session-start-full.js"
if (Test-Path $sessionFullSrc) {
    Copy-Item $sessionFullSrc $hooksDst -Force
    Write-Host "  [ OK ] session-start-full installed" -ForegroundColor Green
}

# ── settings.json ─────────────────────────────────────────────────────────────
Write-Host "Wiring settings.json..." -ForegroundColor Yellow
$settingsPath = "$claudeDir\settings.json"

if (-not (Test-Path $settingsPath)) {
    $settingsSrc = Join-Path $scriptDir "free\hooks\settings.json.example"
    if (Test-Path $settingsSrc) {
        $sc = Get-Content $settingsSrc -Raw
        $sc = $sc -replace '\[VAULT_PATH\]', ($vaultRoot -replace '\\', '/')
        Set-Content -Path $settingsPath -Value $sc -Encoding utf8
        Write-Host "  [ OK ] settings.json created" -ForegroundColor Green
    }
} else {
    Write-Host "  [ OK ] settings.json found -- merging paid hooks" -ForegroundColor Gray
}

function Add-HookIfMissing {
    param($settingsPath, $hookType, $matchStr, $cmd, $label)
    try {
        $s = Get-Content $settingsPath -Raw | ConvertFrom-Json
        $alreadyWired = $false
        $hookArr = if ($hookType -eq "Stop") { $s.hooks.Stop } else { $s.hooks.SessionStart }
        if ($hookArr) {
            foreach ($ent in $hookArr) {
                if ($ent.hooks) {
                    foreach ($h in $ent.hooks) {
                        if ($h.command -like "*$matchStr*") { $alreadyWired = $true }
                    }
                }
            }
        }
        if (-not $alreadyWired) {
            $hookObj = [PSCustomObject]@{ type = "command"; command = $cmd }
            $ent = [PSCustomObject]@{ hooks = @($hookObj) }
            if (-not $s.hooks) { $s | Add-Member -NotePropertyName hooks -NotePropertyValue ([PSCustomObject]@{}) }
            if ($hookType -eq "Stop") {
                if (-not $s.hooks.Stop) { $s.hooks | Add-Member -NotePropertyName Stop -NotePropertyValue @() }
                $s.hooks.Stop = @($s.hooks.Stop) + @($ent)
            } else {
                if (-not $s.hooks.SessionStart) { $s.hooks | Add-Member -NotePropertyName SessionStart -NotePropertyValue @() -Force }
                $s.hooks.SessionStart = @($s.hooks.SessionStart) + @($ent)
            }
            $s | ConvertTo-Json -Depth 10 | Set-Content $settingsPath -Encoding utf8
            Write-Host "  [ OK ] $label wired" -ForegroundColor Green
        } else {
            Write-Host "  [ OK ] $label already wired" -ForegroundColor Gray
        }
    } catch {
        Write-Host "  [WARN] Could not wire ${label}: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

Add-HookIfMissing $settingsPath "Stop"         "vault-logger"       "node `"$claudeDir\hooks\vault-logger.js`""        "Vault-logger"
Add-HookIfMissing $settingsPath "Stop"         "context-bridge"     "node `"$claudeDir\hooks\context-bridge.js`""      "Context-bridge"
Add-HookIfMissing $settingsPath "SessionStart" "session-start-full" "node `"$claudeDir\hooks\session-start-full.js`"" "session-start-full"

# ── Window prompts ─────────────────────────────────────────────────────────────
Write-Host "Installing window prompts..." -ForegroundColor Yellow
$windowSrc = Join-Path $scriptDir "paid\window-prompts-full"
$windowDst = "$claudeDir\window-prompts"
if (Test-Path $windowSrc) {
    New-Item -ItemType Directory -Path $windowDst -Force | Out-Null
    Copy-Item "$windowSrc\*.md" $windowDst -Force
    $count = (Get-ChildItem $windowDst -Filter "*.md").Count
    Write-Host "  [ OK ] $count window prompts installed to ~/.claude/window-prompts/" -ForegroundColor Green
}

# ── Personalization engine + guides ───────────────────────────────────────────
$personSrc = Join-Path $scriptDir "paid\personalization-engine.md"
if (Test-Path $personSrc) {
    Copy-Item $personSrc "$claudeDir\personalization-engine.md" -Force
    Write-Host "  [ OK ] Personalization engine installed" -ForegroundColor Green
}

$graphifySrc = Join-Path $scriptDir "paid\graphify-gitnexus-guide.md"
if (Test-Path $graphifySrc) {
    Copy-Item $graphifySrc "$claudeDir\graphify-gitnexus-guide.md" -Force
    Write-Host "  [ OK ] Graphify + GitNexus guide installed" -ForegroundColor Green
}

# ── Persist CLAUDE_VAULT_PATH ─────────────────────────────────────────────────
Write-Host "Persisting vault path..." -ForegroundColor Yellow
$env:CLAUDE_VAULT_PATH = $vaultRoot

$profilePath = $PROFILE
if (-not $profilePath) { $profilePath = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" }

$profileContent = ""
if (Test-Path $profilePath) { $profileContent = Get-Content $profilePath -Raw -ErrorAction SilentlyContinue }

if ($profileContent -notmatch "CLAUDE_VAULT_PATH") {
    New-Item -ItemType Directory -Path (Split-Path $profilePath -Parent) -Force -ErrorAction SilentlyContinue | Out-Null
    "`n# PowerClaude vault`n`$env:CLAUDE_VAULT_PATH = `"$vaultRoot`"" | Add-Content $profilePath -Encoding utf8
    Write-Host "  [ OK ] CLAUDE_VAULT_PATH added to PowerShell profile" -ForegroundColor Green
} else {
    Write-Host "  [ OK ] CLAUDE_VAULT_PATH already in profile" -ForegroundColor Gray
}

# ── Done ──────────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "---" -ForegroundColor Cyan
Write-Host "PowerClaude installed." -ForegroundColor Green
Write-Host ""
Write-Host "  Vault:          $vaultRoot"
Write-Host "  CLAUDE.md:      $claudeMdPath"
Write-Host "  Hooks:          $claudeDir\hooks\"
Write-Host "  Window prompts: $claudeDir\window-prompts\"
Write-Host ""
Write-Host "One thing left -- run the Personalization Engine:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  1. Open Claude Code"
Write-Host "  2. Start a new session"
Write-Host "  3. Copy and paste the entire contents of this file as your first message:"
Write-Host "     $claudeDir\personalization-engine.md" -ForegroundColor Cyan
Write-Host ""
Write-Host "  13 questions. ~10 minutes. Generates a complete CLAUDE.md, vault," -ForegroundColor Gray
Write-Host "  and hook config built around how you actually work." -ForegroundColor Gray
Write-Host ""
Write-Host "Verify setup: node $claudeDir\validate.js" -ForegroundColor Gray
Write-Host ""
