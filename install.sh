#!/usr/bin/env bash
# PowerClaude Installer - Mac / Linux
# https://github.com/oliverstraus246-beep/powerclaude

set -e

CLAUDE_DIR="$HOME/.claude"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TODAY=$(date +%Y-%m-%d)

echo ""
echo "PowerClaude"
echo "Claude Code, fully configured. In 2 minutes."
echo ""

# Check for Node.js (required for hooks)
if ! command -v node &>/dev/null; then
  echo "  WARNING: Node.js not found. Hooks require Node.js 18+."
  echo "  Install from https://nodejs.org then re-run this installer."
  echo ""
fi

# Step 1: Vault location
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
echo "Creating vault structure..."

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
    echo "  Vault seeded"
else
    echo "# Home" > "$VAULT_ROOT/Home.md"
    echo "  Minimal vault created (run from repo for full seed)"
fi

echo "Setting up ~/.claude..."
mkdir -p "$CLAUDE_DIR"

if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
    cp "$CLAUDE_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md.backup"
    echo "  Existing CLAUDE.md backed up to CLAUDE.md.backup"
fi

TEMPLATE_SRC="$SCRIPT_DIR/free/CLAUDE.md.template"
if [ -f "$TEMPLATE_SRC" ]; then
    cp "$TEMPLATE_SRC" "$CLAUDE_DIR/CLAUDE.md.template"
    echo "  CLAUDE.md.template installed to ~/.claude/"
fi

API_KEYS_PATH="$CLAUDE_DIR/api-keys.json"
if [ ! -f "$API_KEYS_PATH" ]; then
    API_KEYS_SRC="$SCRIPT_DIR/free/api-keys.json.example"
    if [ -f "$API_KEYS_SRC" ]; then
        cp "$API_KEYS_SRC" "$API_KEYS_PATH"
        echo "  api-keys.json created at ~/.claude/"
    fi
fi

echo "Installing hooks..."
mkdir -p "$CLAUDE_DIR/hooks"

HOOKS_SRC="$SCRIPT_DIR/free/hooks"
if [ -d "$HOOKS_SRC" ]; then
    cp "$HOOKS_SRC"/*.js "$CLAUDE_DIR/hooks/" 2>/dev/null || true
    echo "  Hooks installed to ~/.claude/hooks/"
fi

SETTINGS_PATH="$CLAUDE_DIR/settings.json"
if [ -f "$SETTINGS_PATH" ]; then
    echo "  settings.json exists - merge hooks from free/hooks/settings.json.example"
else
    SETTINGS_SRC="$SCRIPT_DIR/free/hooks/settings.json.example"
    if [ -f "$SETTINGS_SRC" ]; then
        sed "s|\[VAULT_PATH\]|$VAULT_ROOT|g" "$SETTINGS_SRC" > "$SETTINGS_PATH"
        echo "  settings.json created"
    fi
fi

echo ""
echo "---"
echo "PowerClaude installed."
echo ""
echo "  Vault:     $VAULT_ROOT"
echo "  Template:  $CLAUDE_DIR/CLAUDE.md.template"
echo "  API keys:  $CLAUDE_DIR/api-keys.json"
echo "  Hooks:     $CLAUDE_DIR/hooks/"
echo ""
echo "IMPORTANT: Persist your vault path so hooks can find it."
echo "  Add this to your ~/.bashrc or ~/.zshrc:"
echo "    export CLAUDE_VAULT_PATH=\"$VAULT_ROOT\""
echo ""
echo "Next steps:"
echo "  1. Add the CLAUDE_VAULT_PATH line above to your shell profile"
echo "  2. cp ~/.claude/CLAUDE.md.template ~/.claude/CLAUDE.md"
echo "  3. Open CLAUDE.md and search for FILL IN -- replace all 9 placeholders"
echo "  4. Open ~/.claude/hooks/user-prompt-submit.js and fill in ACTIVE_PROJECTS"
echo "  5. Open Claude Code -- vault loads automatically"
echo ""
echo "Stuck? See TROUBLESHOOTING.md in the repo."
echo ""
echo "Want a fully generated CLAUDE.md in 7 questions?"
echo "  https://gumroad.com/l/powerclaude - 25 USD one-time"
echo ""
