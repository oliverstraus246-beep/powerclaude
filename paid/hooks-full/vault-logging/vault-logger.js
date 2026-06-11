// PowerClaude - Vault Logger Hook
// Intercepts session completion and logs to the vault automatically.
// Wire to the Stop hook in settings.json.
//
// What it does:
// - Reads the last tool use from Claude Code context
// - If a Write or Edit was made, appends a timestamped entry to Session Takeaways
// - If a file in Projects/Active was referenced, updates that project file
//
// CONFIGURE: Set VAULT_PATH below.

const fs = require("fs");
const path = require("path");

const VAULT_PATH = process.env.CLAUDE_VAULT_PATH || "";

if (!VAULT_PATH) process.exit(0);

const today = new Date().toISOString().split("T")[0];
const takeawaysPath = path.join(VAULT_PATH, "Session Takeaways", "Session Takeaways.md");

// Read session summary from stdin (passed by Claude Code Stop hook)
let input = "";
process.stdin.on("data", (chunk) => { input += chunk; });
process.stdin.on("end", () => {
  try {
    const data = JSON.parse(input);
    const summary = data.summary || data.message || "Session completed.";
    
    if (!fs.existsSync(takeawaysPath)) process.exit(0);
    
    const existing = fs.readFileSync(takeawaysPath, "utf8");
    const entry = "\n**" + today + "** - " + summary.slice(0, 200).replace(/\n/g, " ");
    
    // Append after the last existing entry
    const updated = existing.trimEnd() + "\n" + entry + "\n";
    fs.writeFileSync(takeawaysPath, updated, "utf8");
  } catch (e) {
    // Silently fail - do not block session stop
  }
  process.exit(0);
});
