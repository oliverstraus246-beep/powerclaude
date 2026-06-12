#!/usr/bin/env bash
# PowerClaude Full Installer - Mac / Linux
# Run from the private repo. Installs everything in one pass.
#
#   bash install-full.sh
#
# What gets installed:
#   - Vault structure + seeded templates
#   - Advanced CLAUDE.md (paid template)
#   - Base hooks + paid hooks (vault-logger, context-bridge, session-start-full)
#   - 11 specialized window prompts
#   - Personalization engine (paste into Claude Code to auto-configure everything)
#   - Graphify + GitNexus guide
#   - settings.json with all hooks wired

set -e

CLAUDE_DIR="$HOME/.claude"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TODAY=$(date +%Y-%m-%d)

echo ""
echo "PowerClaude Full Setup"
echo "Installing everything in one pass..."
echo ""

# Check for Node.js
if ! command -v node &>/dev/null; then
  echo "  [WARN] Node.js not found. Hooks require Node 18+."
  echo "         Install from https://nodejs.org then re-run."
  echo ""
fi

# Vault location
echo "Where do you want your Claude vault?"
echo "  [1] $HOME/Documents/Claude  (recommended)"
echo "  [2] $HOME/Claude             (home folder)"
echo "  [3] Enter a custom path"
echo ""
read -rp "Choice [1]: " choice
choice="${choice:-1}"

case "$choice" in
    2) VAULT_ROOT="$HOME/Claude" ;;
    3) read -rp "Enter full path: " VAULT_ROOT ;;
    *) VAULT_ROOT="$HOME/Documents/Claude" ;;
esac

echo ""
echo "  Vault: $VAULT_ROOT"
echo ""

# Create vault
echo "Creating vault..."
mkdir -p \
    "$VAULT_ROOT/User Profile" \
    "$VAULT_ROOT/Projects/Active" \
    "$VAULT_ROOT/Session Takeaways" \
    "$VAULT_ROOT/Decisions Log" \
    "$VAULT_ROOT/Goals and Ideas" \
    "$VAULT_ROOT/Claude and AI" \
    "$VAULT_ROOT/Knowledge Base/Web Development" \
    "$VAULT_ROOT/Knowledge Base/Design" \
    "$VAULT_ROOT/Knowledge Base/Marketing"

VAULT_TEMPLATES="$SCRIPT_DIR/free/vault-templates"
if [ -d "$VAULT_TEMPLATES" ]; then
    find "$VAULT_TEMPLATES" -type f | while read -r tmpl; do
        relative="${tmpl#$VAULT_TEMPLATES/}"
        dest="$VAULT_ROOT/$relative"
        mkdir -p "$(dirname "$dest")"
        sed -e "s/\[TODAY\]/$TODAY/g" \
            -e "s|\[VAULT_ROOT\]|$VAULT_ROOT|g" \
            "$tmpl" > "$dest"
    done
    echo "  [ OK ] Vault seeded"
else
    echo "# Home" > "$VAULT_ROOT/Home.md"
    echo "  [ OK ] Minimal vault created"
fi

# ~/.claude setup
echo "Setting up ~/.claude..."
mkdir -p "$CLAUDE_DIR"

CLAUDE_MD="$CLAUDE_DIR/CLAUDE.md"
if [ -f "$CLAUDE_MD" ]; then
    cp "$CLAUDE_MD" "$CLAUDE_MD.backup"
    echo "  [ OK ] Existing CLAUDE.md backed up"
fi

# Install advanced (paid) template -- falls back to free if not present
ADV_TEMPLATE="$SCRIPT_DIR/paid/advanced-CLAUDE.md.template"
FREE_TEMPLATE="$SCRIPT_DIR/free/CLAUDE.md.template"
if [ -f "$ADV_TEMPLATE" ]; then
    cp "$ADV_TEMPLATE" "$CLAUDE_DIR/CLAUDE.md.template"
    cp "$ADV_TEMPLATE" "$CLAUDE_MD"
    echo "  [ OK ] Advanced CLAUDE.md installed"
elif [ -f "$FREE_TEMPLATE" ]; then
    cp "$FREE_TEMPLATE" "$CLAUDE_DIR/CLAUDE.md.template"
    cp "$FREE_TEMPLATE" "$CLAUDE_MD"
    echo "  [ OK ] CLAUDE.md template installed"
fi

if [ ! -f "$CLAUDE_DIR/api-keys.json" ]; then
    if [ -f "$SCRIPT_DIR/free/api-keys.json.example" ]; then
        cp "$SCRIPT_DIR/free/api-keys.json.example" "$CLAUDE_DIR/api-keys.json"
        echo "  [ OK ] api-keys.json created at ~/.claude/"
    fi
fi

# Hooks
echo "Installing hooks..."
mkdir -p "$CLAUDE_DIR/hooks"

if [ -d "$SCRIPT_DIR/free/hooks" ]; then
    cp "$SCRIPT_DIR/free/hooks"/*.js "$CLAUDE_DIR/hooks/" 2>/dev/null || true
    echo "  [ OK ] Base hooks installed"
fi

if [ -f "$SCRIPT_DIR/validate.js" ]; then
    cp "$SCRIPT_DIR/validate.js" "$CLAUDE_DIR/validate.js"
    echo "  [ OK ] validate.js installed"
fi

# Paid hooks
if [ -f "$SCRIPT_DIR/paid/hooks-full/vault-logging/vault-logger.js" ]; then
    cp "$SCRIPT_DIR/paid/hooks-full/vault-logging/vault-logger.js" "$CLAUDE_DIR/hooks/"
    echo "  [ OK ] Vault-logger installed"
fi

if [ -f "$SCRIPT_DIR/paid/hooks-full/context-bridge/context-bridge.js" ]; then
    cp "$SCRIPT_DIR/paid/hooks-full/context-bridge/context-bridge.js" "$CLAUDE_DIR/hooks/"
    echo "  [ OK ] Context-bridge installed"
fi

if [ -f "$SCRIPT_DIR/paid/hooks-full/context-bridge/session-start-full.js" ]; then
    cp "$SCRIPT_DIR/paid/hooks-full/context-bridge/session-start-full.js" "$CLAUDE_DIR/hooks/"
    echo "  [ OK ] session-start-full installed"
fi

# settings.json
SETTINGS_PATH="$CLAUDE_DIR/settings.json"
if [ ! -f "$SETTINGS_PATH" ]; then
    SETTINGS_SRC="$SCRIPT_DIR/free/hooks/settings.json.example"
    if [ -f "$SETTINGS_SRC" ]; then
        sed "s|\[VAULT_PATH\]|$VAULT_ROOT|g" "$SETTINGS_SRC" > "$SETTINGS_PATH"
        echo "  [ OK ] settings.json created"
    fi
else
    echo "  [ OK ] settings.json found -- merging paid hooks"
fi

# Wire paid hooks via node
if command -v node &>/dev/null && [ -f "$SETTINGS_PATH" ]; then
    node - "$SETTINGS_PATH" "$CLAUDE_DIR" <<'NODESCRIPT'
const fs = require('fs');
const settingsPath = process.argv[2];
const hooksDir = process.argv[3] + '/hooks';

let s = {};
try { s = JSON.parse(fs.readFileSync(settingsPath, 'utf8')); } catch(e) {}
if (!s.hooks) s.hooks = {};

function addHook(type, matchStr, command) {
  if (!s.hooks[type]) s.hooks[type] = [];
  const flat = JSON.stringify(s.hooks[type]);
  if (flat.includes(matchStr)) return;
  s.hooks[type].push({ hooks: [{ type: 'command', command }] });
}

addHook('Stop', 'vault-logger', 'node "' + hooksDir + '/vault-logger.js"');
addHook('Stop', 'context-bridge', 'node "' + hooksDir + '/context-bridge.js"');
addHook('SessionStart', 'session-start-full', 'node "' + hooksDir + '/session-start-full.js"');

fs.writeFileSync(settingsPath, JSON.stringify(s, null, 2));
NODESCRIPT
    echo "  [ OK ] Paid hooks wired in settings.json"
fi

# Window prompts
echo "Installing window prompts..."
WINDOW_SRC="$SCRIPT_DIR/paid/window-prompts-full"
WINDOW_DST="$CLAUDE_DIR/window-prompts"
if [ -d "$WINDOW_SRC" ]; then
    mkdir -p "$WINDOW_DST"
    cp "$WINDOW_SRC"/*.md "$WINDOW_DST/"
    COUNT=$(ls "$WINDOW_DST"/*.md 2>/dev/null | wc -l | tr -d ' ')
    echo "  [ OK ] $COUNT window prompts installed to ~/.claude/window-prompts/"
fi

# Personalization engine + guides
if [ -f "$SCRIPT_DIR/paid/personalization-engine.md" ]; then
    cp "$SCRIPT_DIR/paid/personalization-engine.md" "$CLAUDE_DIR/personalization-engine.md"
    echo "  [ OK ] Personalization engine installed"
fi

if [ -f "$SCRIPT_DIR/paid/graphify-gitnexus-guide.md" ]; then
    cp "$SCRIPT_DIR/paid/graphify-gitnexus-guide.md" "$CLAUDE_DIR/graphify-gitnexus-guide.md"
    echo "  [ OK ] Graphify + GitNexus guide installed"
fi

# Persist CLAUDE_VAULT_PATH
echo "Persisting vault path..."
export CLAUDE_VAULT_PATH="$VAULT_ROOT"

SHELL_PROFILE=""
if [ -f "$HOME/.zshrc" ]; then SHELL_PROFILE="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then SHELL_PROFILE="$HOME/.bashrc"
elif [ -f "$HOME/.bash_profile" ]; then SHELL_PROFILE="$HOME/.bash_profile"
fi

if [ -n "$SHELL_PROFILE" ]; then
    if ! grep -q "CLAUDE_VAULT_PATH" "$SHELL_PROFILE" 2>/dev/null; then
        echo "" >> "$SHELL_PROFILE"
        echo "# PowerClaude vault" >> "$SHELL_PROFILE"
        echo "export CLAUDE_VAULT_PATH=\"$VAULT_ROOT\"" >> "$SHELL_PROFILE"
        echo "  [ OK ] CLAUDE_VAULT_PATH added to $SHELL_PROFILE"
    else
        echo "  [ OK ] CLAUDE_VAULT_PATH already in shell profile"
    fi
fi

echo ""
echo "---"
echo "PowerClaude installed."
echo ""
echo "  Vault:          $VAULT_ROOT"
echo "  CLAUDE.md:      $CLAUDE_MD"
echo "  Hooks:          $CLAUDE_DIR/hooks/"
echo "  Window prompts: $CLAUDE_DIR/window-prompts/"
echo ""
echo "One thing left -- run the Personalization Engine:"
echo ""
echo "  1. Open Claude Code"
echo "  2. Start a new session"
echo "  3. Copy and paste the entire contents of this file as your first message:"
echo "     $CLAUDE_DIR/personalization-engine.md"
echo ""
echo "  13 questions. ~10 minutes. Generates a complete CLAUDE.md, vault,"
echo "  and hook config built around how you actually work."
echo ""
echo "Verify setup: node $CLAUDE_DIR/validate.js"
echo ""
