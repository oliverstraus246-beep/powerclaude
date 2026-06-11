# PowerClaude Installer - Windows (PowerShell)
# https://github.com/oliverstraus246-beep/powerclaude
#
# One-liner install (downloads from GitHub):
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

# When run via irm | iex, PSScriptRoot is empty - download repo to temp
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
        Write-Host "  Download failed. Clone the repo and run install.ps1 from the repo folder instead." -ForegroundColor Red
        exit 1
    }
}

# Check for Node.js (required for hooks)
$nodeVer = node --version 2>$null
if (-not $nodeVer) {
    Write-Host "  WARNING: Node.js not found. Hooks require Node.js 18+." -ForegroundColor Red
    Write-Host "  Install from https://nodejs.org then re-run this installer." -ForegroundColor Yellow
    Write-Host ""
}

Write-Host ""
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
Write-Host "Creating vault structure..." -ForegroundColor Yellow

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
    Write-Host "  CLAUDE.md.template installed to ~/.claude/" -ForegroundColor Green
}

$apiKeysPath = "$claudeDir\api-keys.json"
if (-not (Test-Path $apiKeysPath)) {
    $apiKeysSrc = Join-Path $scriptDir "free\api-keys.json.example"
    if (Test-Path $apiKeysSrc) {
        Copy-Item $apiKeysSrc $apiKeysPath -Force
        Write-Host "  api-keys.json created at ~/.claude/" -ForegroundColor Green
    }
}

Write-Host "Installing hooks..." -ForegroundColor Yellow
$hooksDst = "$claudeDir\hooks"
New-Item -ItemType Directory -Path $hooksDst -Force | Out-Null
$hooksSrc = Join-Path $scriptDir "free\hooks"
if (Test-Path $hooksSrc) {
    Get-ChildItem "$hooksSrc\*.js" | ForEach-Object { Copy-Item $_.FullName $hooksDst -Force }
    Write-Host "  Hooks installed to ~/.claude/hooks/" -ForegroundColor Green
}

$settingsPath = "$claudeDir\settings.json"
if (Test-Path $settingsPath) {
    Write-Host "  settings.json exists - merge hooks from free/hooks/settings.json.example" -ForegroundColor Yellow
} else {
    $settingsSrc = Join-Path $scriptDir "free\hooks\settings.json.example"
    if (Test-Path $settingsSrc) {
        $sc = Get-Content $settingsSrc -Raw
        $sc = $sc -replace '\[VAULT_PATH\]', ($vaultRoot -replace '\\', '/')
        Set-Content -Path $settingsPath -Value $sc -Encoding utf8
        Write-Host "  settings.json created at ~/.claude/" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "---" -ForegroundColor Cyan
Write-Host "PowerClaude installed." -ForegroundColor Green
Write-Host ""
Write-Host "  Vault:     $vaultRoot"
Write-Host "  Template:  $claudeDir\CLAUDE.md.template"
Write-Host "  API keys:  $claudeDir\api-keys.json"
Write-Host "  Hooks:     $claudeDir\hooks\"
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Copy the template: Copy-Item $claudeDir\CLAUDE.md.template $claudeDir\CLAUDE.md"
Write-Host "  2. Fill in the [PLACEHOLDER] sections with your actual paths"
Write-Host "  3. Open Claude Code - vault loads on session start"
Write-Host ""
Write-Host "Want a fully generated CLAUDE.md in 7 questions?" -ForegroundColor Cyan
Write-Host "  https://gumroad.com/l/powerclaude - 25 USD one-time"
Write-Host ""

