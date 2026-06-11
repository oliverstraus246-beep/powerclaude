#!/usr/bin/env bash
# PowerClaude Updater - Mac / Linux
# Pulls the latest version and applies non-destructive updates.
# Your CLAUDE.md, vault, and api-keys.json are never touched.
#
# Run: ./update.sh  (from cloned repo)

set -e
CLAUDE_DIR="$HOME/.claude"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "PowerClaude Updater"
echo ""

# Pull latest
echo "Pulling latest from GitHub..."
git pull origin main
echo "  Up to date"
echo ""

# Update hooks (safe to overwrite - these are not user-edited)
echo "Updating hooks..."
HOOKS_SRC="$SCRIPT_DIR/free/hooks"
if [ -d "$HOOKS_SRC" ]; then
    cp "$HOOKS_SRC"/*.js "$CLAUDE_DIR/hooks/"
    echo "  Hooks updated"
fi

# Update template (not CLAUDE.md itself - that is the user's file)
TMPL_SRC="$SCRIPT_DIR/free/CLAUDE.md.template"
if [ -f "$TMPL_SRC" ]; then
    cp "$TMPL_SRC" "$CLAUDE_DIR/CLAUDE.md.template"
    echo "  CLAUDE.md.template updated"
fi

echo ""
echo "Updated:"
echo "  Hooks:    $CLAUDE_DIR/hooks/"
echo "  Template: $CLAUDE_DIR/CLAUDE.md.template"
echo ""
echo "Not touched (yours to keep):"
echo "  $CLAUDE_DIR/CLAUDE.md"
echo "  $CLAUDE_DIR/api-keys.json"
echo "  $CLAUDE_VAULT_PATH"
echo ""
echo "Run validate.js to confirm everything is still wired correctly:"
echo "  node validate.js"
echo ""
