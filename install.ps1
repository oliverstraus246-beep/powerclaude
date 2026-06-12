# PowerClaude Installer - Windows (PowerShell)
# https://github.com/oliverstraus246-beep/powerclaude
#
# One-liner install (run in PowerShell as admin if needed):
#   irm https://raw.githubusercontent.com/oliverstraus246-beep/powerclaude/main/install.ps1 | iex
#
# From cloned repo:
#   .\install.ps1

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "PowerClaude" -ForegroundColor Cyan
Write-Host "Claude Code, fully configured. In 2 minutes." -ForegroundColor White
Write-Host ""

$claudeDir = "$env:USERPROFILE\.claude"
$today = Get-Date -Format "yyyy-MM-dd"

# When run via irm | iex, PSScriptRoot is empty -- download repo to temp
$scriptDir = $PSScriptRoot
if (-not $scriptDir -or -not (Test-Path (Join-Path ([string]$scriptDir) "free"))) {
    Write-Host "Downloading PowerClaude..." -ForegroundColor Yellow
    $tempBase = Join-Path $env:TEMP "powerclaude-$(Get-Random)"
    New-Item -ItemType Directory -Path $tempBase -Force | Out-Null
    $zipPath = "$tempBase\repo.zip"
    try {
        Invoke-WebRequest "https://github.com/oliverstraus246-beep/powerclaude/archive/refs/heads/main.zip" -OutFile $zipPath -UseBasicParsing
        Expand-Archive $zipPath -DestinationPath $tempBase -Force
        $scriptDir = "$tempBase\powerclaude-main"
        Write-Host "  Downloaded" -ForegroundColor Green
    } catch {
        Write-Host "  Download failed. Clone the repo and run install.ps1 from the repo folder." -ForegroundColor Red
        exit 1
    }
}

# Check for Node.js (required for hooks)
$nodeVer = node --version 2>$null
if (-not $nodeVer) {
    Write-Host "  [WARN] Node.js not found. Hooks require Node 18+." -ForegroundColor Red
    Write-Host "         Install from https://nodejs.org then re-run." -ForegroundColor Yellow
    Write-Host ""
}

# ── Vault location ────────────────────────────────────────────────────────────

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
    Write-Host "  Vault seeded" -ForegroundColor Green
} else {
    Set-Content "$vaultRoot\Home.md" "# Home" -Encoding utf8
    Write-Host "  Minimal vault created" -ForegroundColor Yellow
}

# ── ~/.claude setup ───────────────────────────────────────────────────────────

Write-Host "Setting up ~/.claude..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path $claudeDir -Force | Out-Null

$claudeMdPath = "$claudeDir\CLAUDE.md"
if (Test-Path $claudeMdPath) {
    Copy-Item $claudeMdPath "$claudeMdPath.backup" -Force
    Write-Host "  Existing CLAUDE.md backed up to CLAUDE.md.backup" -ForegroundColor Gray
}

$templateSrc = Join-Path $scriptDir "free\CLAUDE.md.template"
if (Test-Path $templateSrc) {
    Copy-Item $templateSrc "$claudeDir\CLAUDE.md.template" -Force
    # Auto-copy to CLAUDE.md if it doesn't already exist (backup was made above)
    Copy-Item $templateSrc $claudeMdPath -Force
    Write-Host "  CLAUDE.md installed (search 'FILL IN' to personalize)" -ForegroundColor Green
}

$apiKeysPath = "$claudeDir\api-keys.json"
if (-not (Test-Path $apiKeysPath)) {
    $apiKeysSrc = Join-Path $scriptDir "free\api-keys.json.example"
    if (Test-Path $apiKeysSrc) {
        Copy-Item $apiKeysSrc $apiKeysPath -Force
        Write-Host "  api-keys.json created at ~/.claude/" -ForegroundColor Green
    }
}

# ── Hooks ─────────────────────────────────────────────────────────────────────

Write-Host "Installing hooks..." -ForegroundColor Yellow
$hooksDst = "$claudeDir\hooks"
New-Item -ItemType Directory -Path $hooksDst -Force | Out-Null

$hooksSrc = Join-Path $scriptDir "free\hooks"
if (Test-Path $hooksSrc) {
    Get-ChildItem "$hooksSrc\*.js" | ForEach-Object { Copy-Item $_.FullName $hooksDst -Force }
    Write-Host "  Hooks installed to ~/.claude/hooks/" -ForegroundColor Green
}

$validateSrc = Join-Path $scriptDir "validate.js"
if (Test-Path $validateSrc) {
    Copy-Item $validateSrc "$claudeDir\validate.js" -Force
    Write-Host "  validate.js installed to ~/.claude/" -ForegroundColor Green
}

# ── settings.json ─────────────────────────────────────────────────────────────

$settingsPath = "$claudeDir\settings.json"
if (Test-Path $settingsPath) {
    Write-Host "  settings.json already exists -- hooks not overwritten" -ForegroundColor Yellow
    Write-Host "  See free/hooks/settings.json.example to merge hook entries manually" -ForegroundColor Gray
} else {
    $settingsSrc = Join-Path $scriptDir "free\hooks\settings.json.example"
    if (Test-Path $settingsSrc) {
        $sc = Get-Content $settingsSrc -Raw
        $sc = $sc -replace '\[VAULT_PATH\]', ($vaultRoot -replace '\\', '/')
        Set-Content -Path $settingsPath -Value $sc -Encoding utf8
        Write-Host "  settings.json created at ~/.claude/" -ForegroundColor Green
    }
}

# ── Auto-persist CLAUDE_VAULT_PATH in PowerShell profile ──────────────────────

Write-Host "Persisting vault path..." -ForegroundColor Yellow
$env:CLAUDE_VAULT_PATH = $vaultRoot

$profilePath = $PROFILE
if (-not $profilePath) { $profilePath = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" }

$profileContent = ""
if (Test-Path $profilePath) { $profileContent = Get-Content $profilePath -Raw -ErrorAction SilentlyContinue }

if ($profileContent -notmatch "CLAUDE_VAULT_PATH") {
    New-Item -ItemType Directory -Path (Split-Path $profilePath -Parent) -Force -ErrorAction SilentlyContinue | Out-Null
    "`n# PowerClaude vault`n`$env:CLAUDE_VAULT_PATH = `"$vaultRoot`"" | Add-Content $profilePath -Encoding utf8
    Write-Host "  CLAUDE_VAULT_PATH added to PowerShell profile" -ForegroundColor Green
    Write-Host "  (active now and on every future session)" -ForegroundColor Gray
} else {
    Write-Host "  CLAUDE_VAULT_PATH already in profile" -ForegroundColor Gray
}

# ── Done ──────────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "---" -ForegroundColor Cyan
Write-Host "PowerClaude installed." -ForegroundColor Green
Write-Host ""
Write-Host "  Vault:     $vaultRoot"
Write-Host "  CLAUDE.md: $claudeMdPath"
Write-Host "  Hooks:     $claudeDir\hooks\"
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Open $claudeMdPath"
Write-Host "     Search for 'FILL IN' and replace each placeholder (there are 9)"
Write-Host ""
Write-Host "  2. Open $claudeDir\hooks\user-prompt-submit.js"
Write-Host "     Fill in ACTIVE_PROJECTS with your project names and paths"
Write-Host ""
Write-Host "  3. (Optional) Add your Gemini API key to $claudeDir\api-keys.json"
Write-Host "     Free key: https://aistudio.google.com/apikey"
Write-Host "     Enables cheap model routing (saves ~70% on summarization tasks)"
Write-Host ""
Write-Host "  4. Open Claude Code -- your vault loads automatically"
Write-Host ""
Write-Host "Verify setup: node $claudeDir\validate.js" -ForegroundColor Gray
Write-Host "Troubleshooting: TROUBLESHOOTING.md in the repo" -ForegroundColor Gray
Write-Host ""
Write-Host "Want the full setup? Text 303-946-4224 or CashApp: oliverstraus -- $25, lifetime access." -ForegroundColor Cyan
