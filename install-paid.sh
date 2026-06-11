#!/usr/bin/env bash
# PowerClaude - Paid Tier Installer (Mac / Linux)
# Run this AFTER the free installer: bash install.sh
#
# What this installs:
#   - Vault-logger hook (auto-logs every session to your vault)
#   - 11 specialized window prompts -> ~/.claude/window-prompts/
#   - Advanced CLAUDE.md template
#   - Personalization engine

set -e

CLAUDE_DIR="$HOME/.claude"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "PowerClaude - Full Version"
echo "Installing paid tier..."
echo ""

# Verify free tier
if [ ! -f "$CLAUDE_DIR/hooks/session-start.js" ]; then
    echo "[FAIL] Free tier not found. Run install.sh first."
    exit 1
fi

# 1. Vault-logger hook
VAULT_LOGGER_SRC="$SCRIPT_DIR/paid/hooks-full/vault-logging/vault-logger.js"
if [ -f "$VAULT_LOGGER_SRC" ]; then
    cp "$VAULT_LOGGER_SRC" "$CLAUDE_DIR/hooks/"
    echo "  [ OK ] Vault-logger installed to ~/.claude/hooks/"
else
    echo "  [WARN] vault-logger.js not found"
fi

# 2. Wire vault-logger as Stop hook (append to settings.json)
SETTINGS_PATH="$CLAUDE_DIR/settings.json"
if [ -f "$SETTINGS_PATH" ]; then
    if ! grep -q "vault-logger" "$SETTINGS_PATH" 2>/dev/null; then
        echo "  [WARN] Could not auto-wire Stop hook on Mac/Linux."
        echo "         Add this to the 'Stop' array in ~/.claude/settings.json:"
        echo "         { \"hooks\": [{ \"type\": \"command\", \"command\": \"node ~/.claude/hooks/vault-logger.js\" }] }"
    else
        echo "  [ OK ] Vault-logger already in settings.json"
    fi
fi

# 3. Window prompts
WINDOW_SRC="$SCRIPT_DIR/paid/window-prompts-full"
WINDOW_DST="$CLAUDE_DIR/window-prompts"
if [ -d "$WINDOW_SRC" ]; then
    mkdir -p "$WINDOW_DST"
    cp "$WINDOW_SRC"/*.md "$WINDOW_DST/"
    count=$(ls "$WINDOW_DST"/*.md 2>/dev/null | wc -l | tr -d ' ')
    echo "  [ OK ] $count window prompts installed to ~/.claude/window-prompts/"
fi

# 4. Advanced CLAUDE.md template
ADV_TEMPLATE="$SCRIPT_DIR/paid/advanced-CLAUDE.md.template"
if [ -f "$ADV_TEMPLATE" ]; then
    if [ -f "$CLAUDE_DIR/CLAUDE.md.template" ]; then
        cp "$CLAUDE_DIR/CLAUDE.md.template" "$CLAUDE_DIR/CLAUDE.md.template.free-backup"
    fi
    cp "$ADV_TEMPLATE" "$CLAUDE_DIR/CLAUDE.md.template"
    echo "  [ OK ] Advanced CLAUDE.md template installed"
    echo "         (free template backed up to CLAUDE.md.template.free-backup)"
fi

# 5. Personalization engine
if [ -f "$SCRIPT_DIR/paid/personalization-engine.md" ]; then
    cp "$SCRIPT_DIR/paid/personalization-engine.md" "$CLAUDE_DIR/personalization-engine.md"
    echo "  [ OK ] Personalization engine installed"
fi

# 6. Graphify guide
if [ -f "$SCRIPT_DIR/paid/graphify-gitnexus-guide.md" ]; then
    cp "$SCRIPT_DIR/paid/graphify-gitnexus-guide.md" "$CLAUDE_DIR/graphify-gitnexus-guide.md"
    echo "  [ OK ] Graphify + GitNexus guide installed"
fi

echo ""
echo "---"
echo "Paid tier installed."
echo ""
echo "Next steps:"
echo ""
echo "  1. Generate your CLAUDE.md (7 questions, ~2 min):"
echo "     Open Claude Code -> new session -> paste contents of:"
echo "     $CLAUDE_DIR/personalization-engine.md"
echo ""
echo "  2. Use your window prompts:"
echo "     Files are in $CLAUDE_DIR/window-prompts/"
echo "     Open Claude Code -> new session -> paste any .md as your first message"
echo ""
echo "  3. Vault-logger is active (auto-logs sessions to vault)"
echo ""
echo "Verify: node $CLAUDE_DIR/validate.js"
echo ""
