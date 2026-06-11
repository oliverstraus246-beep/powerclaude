// PowerClaude - UserPromptSubmit Hook
// Injects a lean context summary on the first message of each new conversation.
// Install: copy to ~/.claude/hooks/user-prompt-submit.js
// Wire: add to ~/.claude/settings.json under "UserPromptSubmit"
//
// SETUP: Set VAULT_PATH and fill in your active projects below.

const fs = require("fs");
const path = require("path");

// CONFIGURE THESE:
const VAULT_PATH = process.env.CLAUDE_VAULT_PATH || "";
const ACTIVE_PROJECTS = [
  // { name: "My Project", path: "C:/path/to/project", stack: "React + Node" },
];
const MUST_DO_RULES = [
  // "Frontend/UI -> invoke ui-ux-pro-max skill FIRST",
  // "Bug/debugging -> invoke systematic-debugging skill",
  // "Choices -> AskUserQuestion pop-up - never plain-text options list",
];

// Build context summary
const lines = ["ACTIVE PROJECTS"];
for (const p of ACTIVE_PROJECTS) {
  lines.push("  " + p.name + " -> " + p.path + " (" + p.stack + ")");
}

if (MUST_DO_RULES.length > 0) {
  lines.push("", "MUST-DO RULES");
  for (const r of MUST_DO_RULES) {
    lines.push("  * " + r);
  }
}

// Try to get last session takeaway from vault
if (VAULT_PATH) {
  const takeawaysPath = path.join(VAULT_PATH, "Session Takeaways", "Session Takeaways.md");
  if (fs.existsSync(takeawaysPath)) {
    try {
      const content = fs.readFileSync(takeawaysPath, "utf8");
      const lastEntry = content.split("\n").filter(l => l.match(/^\*\*\d{4}-\d{2}-\d{2}\*\*/)).pop();
      if (lastEntry) {
        lines.push("", "LAST SESSION: " + lastEntry.replace(/^\*\*[\d-]+\*\* — /, "").trim());
      }
    } catch (e) {
      // Silently skip
    }
  }
}

if (lines.length > 1) {
  process.stdout.write(
    JSON.stringify({
      type: "context",
      content: lines.join("\n"),
    })
  );
}
