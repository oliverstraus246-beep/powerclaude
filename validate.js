#!/usr/bin/env node
// PowerClaude Setup Validator
// Run this to check if your setup is configured correctly:
//   node ~/.claude/validate.js          (after running the installer)
//   node validate.js                    (from the cloned repo)

const fs = require("fs");
const path = require("path");
const { execSync } = require("child_process");

let passed = 0, failed = 0, warnings = 0;

function ok(label) {
  console.log("  ✓  " + label);
  passed++;
}
function warn(label, detail) {
  console.log("  ⚠  " + label);
  if (detail) console.log("       -> " + detail);
  warnings++;
}
function fail(label, detail) {
  console.log("  ✗  " + label);
  if (detail) console.log("       -> " + detail);
  failed++;
}

const claudeDir = path.join(process.env.USERPROFILE || process.env.HOME, ".claude");
const vaultPath = process.env.CLAUDE_VAULT_PATH || "";

console.log("\nPowerClaude Setup Validator");
console.log("============================\n");

// ── Runtime ──────────────────────────────────────────────
console.log("Runtime");

const nodeMajor = parseInt(process.version.slice(1));
if (nodeMajor >= 18) {
  ok("Node.js " + process.version);
} else {
  fail("Node.js " + process.version + " is too old", "Install 18+ from https://nodejs.org");
}

try {
  execSync("llm --version", { stdio: "pipe" });
  ok("llm CLI installed");
} catch (_) {
  warn("llm CLI not found", "Install: pip install llm  (needed for Gemini model routing)");
}

// ── Vault ─────────────────────────────────────────────────
console.log("\nVault");

if (vaultPath) {
  ok("CLAUDE_VAULT_PATH set: " + vaultPath);
  const homeMd = path.join(vaultPath, "Home.md");
  if (fs.existsSync(homeMd)) {
    ok("Home.md exists");
  } else {
    fail("Home.md not found at " + homeMd, "Re-run the installer to seed the vault");
  }
} else {
  fail("CLAUDE_VAULT_PATH not set", "Add to shell profile: $env:CLAUDE_VAULT_PATH = \"C:\\path\\to\\vault\"");
}

// ── ~/.claude ─────────────────────────────────────────────
console.log("\n~/.claude");

if (!fs.existsSync(claudeDir)) {
  fail("~/.claude directory missing", "Run the PowerClaude installer");
} else {
  ok("~/.claude exists");
}

const claudeMd = path.join(claudeDir, "CLAUDE.md");
if (fs.existsSync(claudeMd)) {
  ok("CLAUDE.md installed");
  const content = fs.readFileSync(claudeMd, "utf8");
  const fillCount = (content.match(/FILL IN/g) || []).length;
  const placeholders = (content.match(/\[YOUR_[A-Z_]+\]/g) || []);
  if (fillCount === 0 && placeholders.length === 0) {
    ok("CLAUDE.md fully personalized");
  } else {
    const issues = [];
    if (fillCount > 0) issues.push(fillCount + " FILL IN marker(s)");
    if (placeholders.length > 0) issues.push("unfilled: " + [...new Set(placeholders)].join(", "));
    warn("CLAUDE.md has " + issues.join(" and "), "Open ~/.claude/CLAUDE.md and search for FILL IN");
  }
} else {
  fail("CLAUDE.md not found", "Run: Copy-Item ~/.claude/CLAUDE.md.template ~/.claude/CLAUDE.md");
}

const apiKeys = path.join(claudeDir, "api-keys.json");
if (fs.existsSync(apiKeys)) {
  try {
    const keys = JSON.parse(fs.readFileSync(apiKeys, "utf8"));
    const gemini = keys.find(k => k.envVar === "GEMINI_API_KEY");
    if (gemini && gemini.value && !gemini.value.includes("YOUR_")) {
      ok("Gemini API key configured");
    } else {
      warn("Gemini API key not filled in", "Edit ~/.claude/api-keys.json  |  Free key: https://aistudio.google.com/apikey");
    }
  } catch (_) {
    warn("api-keys.json has invalid JSON", "Check for syntax errors");
  }
} else {
  warn("api-keys.json missing", "Copy from free/api-keys.json.example");
}

// ── Hooks ─────────────────────────────────────────────────
console.log("\nHooks");

const hooksDir = path.join(claudeDir, "hooks");
const sessionStart = path.join(hooksDir, "session-start.js");
const userPrompt = path.join(hooksDir, "user-prompt-submit.js");

if (fs.existsSync(sessionStart)) {
  ok("session-start.js installed");
} else {
  fail("session-start.js missing from ~/.claude/hooks/", "Re-run the installer");
}

if (fs.existsSync(userPrompt)) {
  ok("user-prompt-submit.js installed");
  const content = fs.readFileSync(userPrompt, "utf8");
  if (content.match(/^\s*\{\s*name\s*:/m)) {
    ok("ACTIVE_PROJECTS has entries");
  } else {
    warn("ACTIVE_PROJECTS is empty", "Open ~/.claude/hooks/user-prompt-submit.js and add your projects");
  }
} else {
  fail("user-prompt-submit.js missing from ~/.claude/hooks/", "Re-run the installer");
}

const settingsPath = path.join(claudeDir, "settings.json");
if (fs.existsSync(settingsPath)) {
  try {
    const s = JSON.parse(fs.readFileSync(settingsPath, "utf8"));
    ok("settings.json is valid JSON");
    if (s.hooks && s.hooks.SessionStart && s.hooks.SessionStart.length > 0) {
      ok("SessionStart hook wired");
    } else {
      warn("SessionStart hook missing from settings.json", "See free/hooks/settings.json.example");
    }
    if (s.hooks && s.hooks.UserPromptSubmit && s.hooks.UserPromptSubmit.length > 0) {
      ok("UserPromptSubmit hook wired");
    } else {
      warn("UserPromptSubmit hook missing from settings.json", "See free/hooks/settings.json.example");
    }
  } catch (e) {
    fail("settings.json has invalid JSON", e.message);
  }
} else {
  fail("settings.json not found", "Copy from free/hooks/settings.json.example to ~/.claude/settings.json");
}

// ── Summary ────────────────────────────────────────────────
console.log("\n============================");
console.log(
  "  " + passed + " passed   " +
  warnings + " warnings   " +
  failed + " failed\n"
);

if (failed > 0) {
  console.log("Fix the ✗ items above, then re-run: node validate.js");
  console.log("See TROUBLESHOOTING.md for help.\n");
  process.exit(1);
} else if (warnings > 0) {
  console.log("Setup is functional. Address ⚠ warnings for full capability.\n");
} else {
  console.log("Everything looks good. Open Claude Code and start building.\n");
}
