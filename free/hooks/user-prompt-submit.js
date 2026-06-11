// PowerClaude - UserPromptSubmit Hook
// Injects a lean context summary on the first message of each new conversation.
// Install: copy to ~/.claude/hooks/user-prompt-submit.js
// Wire: add to ~/.claude/settings.json under "UserPromptSubmit"
//
// SETUP: Fill in ACTIVE_PROJECTS and MUST_DO_RULES below, then save.
// The hook reads CLAUDE_VAULT_PATH from your environment (set by the installer).

const fs = require("fs");
const path = require("path");

// ============================================================
// CONFIGURE THESE (replace examples with your real projects)
// ============================================================

const VAULT_PATH = process.env.CLAUDE_VAULT_PATH || "";

const ACTIVE_PROJECTS = [
  // Uncomment and fill in your projects:
  // { name: "My App", path: "C:/Users/me/my-app", stack: "React + Node" },
  // { name: "API Server", path: "C:/Users/me/api", stack: "Express + PostgreSQL" },
];

const MUST_DO_RULES = [
  // Rules Claude follows every session. Uncomment and customize:
  // "Frontend/UI work -> invoke ui-ux-pro-max skill FIRST",
  // "Debugging -> invoke systematic-debugging skill",
  // "Choices with options -> use AskUserQuestion pop-up, never plain text lists",
];

// ============================================================

const lines = [];

if (ACTIVE_PROJECTS.length > 0) {
  lines.push("ACTIVE PROJECTS");
  for (const p of ACTIVE_PROJECTS) {
    lines.push("  " + p.name + " -> " + p.path + " (" + p.stack + ")");
  }
}

if (MUST_DO_RULES.length > 0) {
  lines.push("", "MUST-DO RULES");
  for (const r of MUST_DO_RULES) {
    lines.push("  * " + r);
  }
}

// Pull last session summary from vault (if vault is configured)
if (VAULT_PATH) {
  const takeawaysPath = path.join(VAULT_PATH, "Session Takeaways", "Session Takeaways.md");
  if (fs.existsSync(takeawaysPath)) {
    try {
      const content = fs.readFileSync(takeawaysPath, "utf8");
      // Match lines starting with a bold date: **YYYY-MM-DD**
      const lastEntry = content
        .split("\n")
        .filter((l) => l.match(/^\*\*\d{4}-\d{2}-\d{2}\*\*/))
        .pop();
      if (lastEntry) {
        // Strip the date prefix (handles both em dash and regular dash separators)
        const summary = lastEntry
          .replace(/^\*\*[\d-]+\*\*\s*[-—]\s*/, "")
          .trim();
        if (summary) {
          lines.push("", "LAST SESSION: " + summary);
        }
      }
    } catch (_) {
      // Skip - vault read failure should not block the session
    }
  }
}

// Only output if there is something to say
if (lines.length > 0) {
  process.stdout.write(
    JSON.stringify({
      type: "context",
      content: lines.join("\n"),
    })
  );
}
