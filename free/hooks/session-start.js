// PowerClaude - SessionStart Hook
// Reads your vault Home.md and injects it into context on every session launch.
// Install: copy to ~/.claude/hooks/session-start.js
// Wire: add to ~/.claude/settings.json under "SessionStart"
//
// SETUP: Set VAULT_PATH below to your actual vault root.

const fs = require("fs");
const path = require("path");

// CONFIGURE THIS:
const VAULT_PATH = process.env.CLAUDE_VAULT_PATH || "";

if (!VAULT_PATH) {
  // If not configured, output nothing (hook silently skips)
  process.exit(0);
}

const homePath = path.join(VAULT_PATH, "Home.md");

if (!fs.existsSync(homePath)) {
  process.exit(0);
}

try {
  const content = fs.readFileSync(homePath, "utf8");
  // Output format: Claude Code hooks inject stdout into context
  process.stdout.write(
    JSON.stringify({
      type: "context",
      content: "VAULT HOME:\n" + content,
    })
  );
} catch (err) {
  // Silently fail - do not block session start
  process.exit(0);
}
