// PowerClaude - SessionStart Hook
// Reads your vault Home.md and injects it into context on every session launch.
// Install: copy to ~/.claude/hooks/session-start.js
// Wire: add to ~/.claude/settings.json under "SessionStart"
//
// SETUP: Set the CLAUDE_VAULT_PATH environment variable to your vault root.
// The installer does this automatically. To set it manually:
//   Windows: $env:CLAUDE_VAULT_PATH = "C:\Users\you\Documents\Claude"
//   Mac/Linux: export CLAUDE_VAULT_PATH="$HOME/Documents/Claude"
// Add it to your shell profile (~/.bashrc, ~/.zshrc, or PowerShell $PROFILE) for persistence.

const fs = require("fs");
const path = require("path");

const VAULT_PATH = process.env.CLAUDE_VAULT_PATH || "";

if (!VAULT_PATH) {
  // Warn on stderr so the user knows why vault context is missing
  process.stderr.write(
    "[PowerClaude] CLAUDE_VAULT_PATH is not set. Vault context will not load.\n" +
    "  Set it in your shell profile: export CLAUDE_VAULT_PATH=\"/path/to/vault\"\n"
  );
  process.exit(0);
}

const homePath = path.join(VAULT_PATH, "Home.md");

if (!fs.existsSync(homePath)) {
  process.stderr.write(
    "[PowerClaude] Home.md not found at: " + homePath + "\n" +
    "  Run the installer to seed your vault, or create Home.md manually.\n"
  );
  process.exit(0);
}

try {
  const content = fs.readFileSync(homePath, "utf8");
  process.stdout.write(
    JSON.stringify({
      type: "context",
      content: "VAULT HOME:\n" + content,
    })
  );
} catch (err) {
  process.stderr.write("[PowerClaude] Failed to read Home.md: " + err.message + "\n");
  process.exit(0);
}
