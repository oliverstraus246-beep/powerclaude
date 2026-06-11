#!/usr/bin/env bash
# PowerClaude Updater - Mac / Linux
# Updates hooks and validate.js. Does NOT touch CLAUDE.md, vault, api-keys.json.

set -e
CLAUDE_DIR="$HOME/.claude"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "PowerClaude Updater"
echo ""

if [ ! -d "$CLAUDE_DIR/hooks" ]; then
    echo "  [FAIL] ~/.claude/hooks not found. Run install.sh first."
    exit 1
fi

# If not in repo, download it
if [ ! -d "$SCRIPT_DIR/free" ]; then
    echo "Downloading latest PowerClaude..."
    TMPDIR=$(mktemp -d)
    curl -fsSL "https://github.com/oliverstraus246-beep/powerclaude/archive/refs/heads/main.zip" -o "$TMPDIR/repo.zip"
    unzip -q "$TMPDIR/repo.zip" -d "$TMPDIR"
    SCRIPT_DIR="$TMPDIR/powerclaude-main"
fi

# Update hooks
if [ -d "$SCRIPT_DIR/free/hooks" ]; then
    for f in "$SCRIPT_DIR/free/hooks"/*.js; do
        cp "$f" "$CLAUDE_DIR/hooks/"
        echo "  Updated: hooks/$(basename $f)"
    done
fi

# Update validate.js
if [ -f "$SCRIPT_DIR/validate.js" ]; then
    cp "$SCRIPT_DIR/validate.js" "$CLAUDE_DIR/validate.js"
    echo "  Updated: validate.js"
fi

echo ""
echo "Update complete."
echo "  CLAUDE.md, vault, api-keys.json, and settings.json were not changed."
echo ""
