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
    echo "  Vault seeded"
else
    echo "# Home" > "$VAULT_ROOT/Home.md"
    echo "  Minimal vault created"
fi

# ~/.claude setup
echo "Setting up ~/.claude..."
mkdir -p "$CLAUDE_DIR"

CLAUDE_MD="$CLAUDE_DIR/CLAUDE.md"
if [ -f "$CLAUDE_MD" ]; then
    cp "$CLAUDE_MD" "$CLAUDE_MD.backup"
    echo "  Existing CLAUDE.md backed up"
fi

TEMPLATE_SRC="$SCRIPT_DIR/free/CLAUDE.md.template"
if [ -f "$TEMPLATE_SRC" ]; then
    cp "$TEMPLATE_SRC" "$CLAUDE_DIR/CLAUDE.md.template"
    cp "$TEMPLATE_SRC" "$CLAUDE_MD"
    echo "  CLAUDE.md installed (search 'FILL IN' to personalize)"
fi

if [ ! -f "$CLAUDE_DIR/api-keys.json" ]; then
    if [ -f "$SCRIPT_DIR/free/api-keys.json.example" ]; then
        cp "$SCRIPT_DIR/free/api-keys.json.example" "$CLAUDE_DIR/api-keys.json"
        echo "  api-keys.json created at ~/.claude/"
    fi
fi

# Hooks
echo "Installing hooks..."
mkdir -p "$CLAUDE_DIR/hooks"

if [ -d "$SCRIPT_DIR/free/hooks" ]; then
    cp "$SCRIPT_DIR/free/hooks"/*.js "$CLAUDE_DIR/hooks/" 2>/dev/null || true
    echo "  Hooks installed to ~/.claude/hooks/"
fi

if [ -f "$SCRIPT_DIR/validate.js" ]; then
    cp "$SCRIPT_DIR/validate.js" "$CLAUDE_DIR/validate.js"
    echo "  validate.js installed to ~/.claude/"
fi

# settings.json
SETTINGS_PATH="$CLAUDE_DIR/settings.json"
if [ -f "$SETTINGS_PATH" ]; then
    echo "  settings.json already exists -- hooks not overwritten"
    echo "  See free/hooks/settings.json.example to merge hook entries"
else
    SETTINGS_SRC="$SCRIPT_DIR/free/hooks/settings.json.example"
    if [ -f "$SETTINGS_SRC" ]; then
        sed "s|\[VAULT_PATH\]|$VAULT_ROOT|g" "$SETTINGS_SRC" > "$SETTINGS_PATH"
        echo "  settings.json created"
    fi
fi

# Auto-persist CLAUDE_VAULT_PATH in shell profile
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
        echo "  CLAUDE_VAULT_PATH added to $SHELL_PROFILE"
        echo "  (active now and on every future session)"
    else
        echo "  CLAUDE_VAULT_PATH already in shell profile"
    fi
else
    echo "  Could not detect shell profile. Add this manually:"
    echo "    export CLAUDE_VAULT_PATH=\"$VAULT_ROOT\""
fi

echo ""
echo "---"
echo "PowerClaude installed."
echo ""
echo "  Vault:     $VAULT_ROOT"
echo "  CLAUDE.md: $CLAUDE_MD"
echo "  Hooks:     $CLAUDE_DIR/hooks/"
echo ""
echo "Next steps:"
echo "  1. Open $CLAUDE_MD"
echo "     Search for 'FILL IN' and replace each placeholder (there are 9)"
echo ""
echo "  2. Open $CLAUDE_DIR/hooks/user-prompt-submit.js"
echo "     Fill in ACTIVE_PROJECTS with your project names and paths"
echo ""
echo "  3. (Optional) Add your Gemini API key to $CLAUDE_DIR/api-keys.json"
echo "     Free key: https://aistudio.google.com/apikey"
echo "     Enables cheap model routing (saves ~70% on summarization tasks)"
echo ""
echo "  4. Open Claude Code -- your vault loads automatically"
echo ""
echo "Verify setup: node $CLAUDE_DIR/validate.js"
echo "Troubleshooting: TROUBLESHOOTING.md in the repo"
echo ""
echo "Want the full setup? Text 303-946-4224 or CashApp: oliverstraus -- $25, lifetime access."
